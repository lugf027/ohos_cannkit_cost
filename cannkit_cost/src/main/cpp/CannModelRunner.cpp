#include "CannModelRunner.h"

#include "CANNKit/hiai_helper.h"
#include "CANNKit/hiai_options.h"
#include <cstring>
#include <hilog/log.h>

#undef LOG_DOMAIN
#define LOG_DOMAIN 0x3200
#undef LOG_TAG
#define LOG_TAG "CannKitCost"

CannModelRunner &CannModelRunner::GetInstance()
{
    static CannModelRunner instance;
    return instance;
}

CannModelRunner::~CannModelRunner()
{
    Unload();
}

OH_NN_ReturnCode CannModelRunner::Initialize(std::string &message)
{
    const size_t *deviceIds = nullptr;
    uint32_t deviceCount = 0;
    OH_NN_ReturnCode result = OH_NNDevice_GetAllDevicesID(&deviceIds, &deviceCount);
    if (result != OH_NN_SUCCESS || deviceIds == nullptr || deviceCount == 0) {
        message = "未找到 CANN 推理设备";
        return result == OH_NN_SUCCESS ? OH_NN_FAILED : result;
    }

    for (uint32_t index = 0; index < deviceCount; ++index) {
        const char *deviceName = nullptr;
        result = OH_NNDevice_GetName(deviceIds[index], &deviceName);
        if (result == OH_NN_SUCCESS && deviceName != nullptr && std::string(deviceName) == "HIAI_F") {
            deviceId_ = deviceIds[index];
            initialized_ = true;
            message = "HIAI_F 设备初始化成功";
            return OH_NN_SUCCESS;
        }
    }

    message = "当前设备不支持 HIAI_F";
    return OH_NN_FAILED;
}

OH_NN_ReturnCode CannModelRunner::Load(const uint8_t *modelData, size_t modelSize, std::string &message)
{
    if (!initialized_) {
        OH_NN_ReturnCode result = Initialize(message);
        if (result != OH_NN_SUCCESS) {
            return result;
        }
    }
    if (modelData == nullptr || modelSize == 0) {
        message = "模型数据为空";
        return OH_NN_INVALID_PARAMETER;
    }

    Unload();
    HiAI_Compatibility compatibility = HMS_HiAICompatibility_CheckFromBuffer(modelData, modelSize);
    OH_LOG_INFO(LOG_APP, "Model compatibility: %{public}d", compatibility);

    OH_NNCompilation *compilation =
        OH_NNCompilation_ConstructWithOfflineModelBuffer(modelData, modelSize);
    if (compilation == nullptr) {
        message = "创建模型编译实例失败";
        return OH_NN_FAILED;
    }

    OH_NN_ReturnCode result = OH_NNCompilation_SetDevice(compilation, deviceId_);
    if (result == OH_NN_SUCCESS) {
        HiAI_ExecuteDevice devices[] = {HiAI_ExecuteDevice::HIAI_EXECUTE_DEVICE_NPU};
        result = HMS_HiAIOptions_SetModelDeviceOrder(compilation, devices, 1);
    }
    if (result == OH_NN_SUCCESS) {
        result = HMS_HiAIOptions_SetBandMode(compilation, HiAI_BandMode::HIAI_BANDMODE_NORMAL);
    }
    if (result == OH_NN_SUCCESS) {
        result = OH_NNCompilation_Build(compilation);
    }
    if (result == OH_NN_SUCCESS) {
        executor_ = OH_NNExecutor_Construct(compilation);
        if (executor_ == nullptr) {
            result = OH_NN_FAILED;
        }
    }
    OH_NNCompilation_Destroy(&compilation);

    if (result != OH_NN_SUCCESS) {
        message = "模型编译或执行器创建失败，错误码: " + std::to_string(result);
        Unload();
        return result;
    }

    result = CreateTensors(message);
    if (result != OH_NN_SUCCESS) {
        Unload();
        return result;
    }
    message = "模型加载及输入输出 Tensor 创建成功";
    return OH_NN_SUCCESS;
}

OH_NN_ReturnCode CannModelRunner::CreateTensors(std::string &message)
{
    size_t inputCount = 0;
    OH_NN_ReturnCode result = OH_NNExecutor_GetInputCount(executor_, &inputCount);
    if (result != OH_NN_SUCCESS || inputCount == 0) {
        message = "读取模型输入信息失败";
        return result == OH_NN_SUCCESS ? OH_NN_FAILED : result;
    }

    for (size_t index = 0; index < inputCount; ++index) {
        NN_TensorDesc *desc = OH_NNExecutor_CreateInputTensorDesc(executor_, index);
        NN_Tensor *tensor = desc == nullptr ? nullptr : OH_NNTensor_Create(deviceId_, desc);
        OH_NNTensorDesc_Destroy(&desc);
        if (tensor == nullptr) {
            message = "创建输入 Tensor 失败";
            DestroyTensors(inputTensors_);
            return OH_NN_FAILED;
        }
        void *buffer = OH_NNTensor_GetDataBuffer(tensor);
        size_t size = 0;
        result = OH_NNTensor_GetSize(tensor, &size);
        if (result != OH_NN_SUCCESS || buffer == nullptr || size == 0) {
            OH_NNTensor_Destroy(&tensor);
            DestroyTensors(inputTensors_);
            message = "获取输入 Tensor 内存失败";
            return OH_NN_FAILED;
        }
        std::memset(buffer, 0, size);
        inputTensors_.push_back(tensor);
    }

    size_t outputCount = 0;
    result = OH_NNExecutor_GetOutputCount(executor_, &outputCount);
    if (result != OH_NN_SUCCESS || outputCount == 0) {
        message = "读取模型输出信息失败";
        DestroyTensors(inputTensors_);
        return result == OH_NN_SUCCESS ? OH_NN_FAILED : result;
    }
    for (size_t index = 0; index < outputCount; ++index) {
        NN_TensorDesc *desc = OH_NNExecutor_CreateOutputTensorDesc(executor_, index);
        NN_Tensor *tensor = desc == nullptr ? nullptr : OH_NNTensor_Create(deviceId_, desc);
        OH_NNTensorDesc_Destroy(&desc);
        if (tensor == nullptr) {
            message = "创建输出 Tensor 失败";
            DestroyTensors(inputTensors_);
            DestroyTensors(outputTensors_);
            return OH_NN_FAILED;
        }
        outputTensors_.push_back(tensor);
    }
    return OH_NN_SUCCESS;
}

OH_NN_ReturnCode CannModelRunner::RunOnce(std::string &message)
{
    if (executor_ == nullptr || inputTensors_.empty() || outputTensors_.empty()) {
        message = "请先加载模型";
        return OH_NN_FAILED;
    }
    OH_NN_ReturnCode result = OH_NNExecutor_RunSync(executor_, inputTensors_.data(),
        inputTensors_.size(), outputTensors_.data(), outputTensors_.size());
    if (result != OH_NN_SUCCESS) {
        message = "同步推理失败，错误码: " + std::to_string(result);
        return result;
    }
    message = "推理完成";
    return OH_NN_SUCCESS;
}

void CannModelRunner::DestroyTensors(std::vector<NN_Tensor *> &tensors)
{
    for (NN_Tensor *tensor : tensors) {
        OH_NNTensor_Destroy(&tensor);
    }
    tensors.clear();
}

void CannModelRunner::Unload()
{
    DestroyTensors(inputTensors_);
    DestroyTensors(outputTensors_);
    if (executor_ != nullptr) {
        OH_NNExecutor_Destroy(&executor_);
    }
}

size_t CannModelRunner::GetInputCount() const
{
    return inputTensors_.size();
}

size_t CannModelRunner::GetOutputCount() const
{
    return outputTensors_.size();
}
