#include "CannModelRunner.h"

#include "napi/native_api.h"
#include <algorithm>
#include <chrono>
#include <limits>
#include <memory>
#include <rawfile/raw_file_manager.h>
#include <string>

namespace {
using Clock = std::chrono::steady_clock;

double ElapsedMs(Clock::time_point start)
{
    return std::chrono::duration<double, std::milli>(Clock::now() - start).count();
}

void SetBoolean(napi_env env, napi_value object, const char *name, bool value)
{
    napi_value property = nullptr;
    napi_get_boolean(env, value, &property);
    napi_set_named_property(env, object, name, property);
}

void SetNumber(napi_env env, napi_value object, const char *name, double value)
{
    napi_value property = nullptr;
    napi_create_double(env, value, &property);
    napi_set_named_property(env, object, name, property);
}

void SetString(napi_env env, napi_value object, const char *name, const std::string &value)
{
    napi_value property = nullptr;
    napi_create_string_utf8(env, value.c_str(), value.size(), &property);
    napi_set_named_property(env, object, name, property);
}

napi_value CreateResult(napi_env env, bool success, const std::string &message, double durationMs)
{
    napi_value result = nullptr;
    napi_create_object(env, &result);
    SetBoolean(env, result, "success", success);
    SetString(env, result, "message", message);
    SetNumber(env, result, "durationMs", durationMs);
    return result;
}

bool ReadString(napi_env env, napi_value value, std::string &result)
{
    size_t length = 0;
    if (napi_get_value_string_utf8(env, value, nullptr, 0, &length) != napi_ok) {
        return false;
    }
    std::vector<char> buffer(length + 1);
    if (napi_get_value_string_utf8(env, value, buffer.data(), buffer.size(), &length) != napi_ok) {
        return false;
    }
    result.assign(buffer.data(), length);
    return true;
}

napi_value Initialize(napi_env env, napi_callback_info info)
{
    auto start = Clock::now();
    std::string message;
    OH_NN_ReturnCode code = CannModelRunner::GetInstance().Initialize(message);
    return CreateResult(env, code == OH_NN_SUCCESS, message, ElapsedMs(start));
}

napi_value LoadModel(napi_env env, napi_callback_info info)
{
    size_t argc = 2;
    napi_value argv[2] = {nullptr, nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    if (argc != 2) {
        return CreateResult(env, false, "加载模型参数不完整", 0);
    }

    std::string modelPath;
    if (!ReadString(env, argv[1], modelPath)) {
        return CreateResult(env, false, "模型路径无效", 0);
    }
    NativeResourceManager *resourceManager =
        OH_ResourceManager_InitNativeResourceManager(env, argv[0]);
    if (resourceManager == nullptr) {
        return CreateResult(env, false, "获取 ResourceManager 失败", 0);
    }
    RawFile *rawFile = OH_ResourceManager_OpenRawFile(resourceManager, modelPath.c_str());
    if (rawFile == nullptr) {
        OH_ResourceManager_ReleaseNativeResourceManager(resourceManager);
        return CreateResult(env, false, "打开模型 rawfile 失败: " + modelPath, 0);
    }

    long rawSize = OH_ResourceManager_GetRawFileSize(rawFile);
    std::unique_ptr<uint8_t[]> modelData =
        rawSize > 0 ? std::make_unique<uint8_t[]>(static_cast<size_t>(rawSize)) : nullptr;
    int readSize = modelData == nullptr ? 0 :
        OH_ResourceManager_ReadRawFile(rawFile, modelData.get(), static_cast<size_t>(rawSize));
    OH_ResourceManager_CloseRawFile(rawFile);
    OH_ResourceManager_ReleaseNativeResourceManager(resourceManager);
    if (readSize != rawSize) {
        return CreateResult(env, false, "读取模型文件失败", 0);
    }

    auto start = Clock::now();
    std::string message;
    OH_NN_ReturnCode code = CannModelRunner::GetInstance().Load(
        modelData.get(), static_cast<size_t>(rawSize), message);
    napi_value result = CreateResult(env, code == OH_NN_SUCCESS, message, ElapsedMs(start));
    SetNumber(env, result, "inputCount",
        static_cast<double>(CannModelRunner::GetInstance().GetInputCount()));
    SetNumber(env, result, "outputCount",
        static_cast<double>(CannModelRunner::GetInstance().GetOutputCount()));
    return result;
}

napi_value Run(napi_env env, napi_callback_info info)
{
    size_t argc = 1;
    napi_value argv[1] = {nullptr};
    napi_get_cb_info(env, info, &argc, argv, nullptr, nullptr);
    int32_t count = 0;
    if (argc != 1 || napi_get_value_int32(env, argv[0], &count) != napi_ok ||
        count < 1 || count > 10000) {
        return CreateResult(env, false, "运行次数必须在 1 到 10000 之间", 0);
    }

    double totalMs = 0;
    double minMs = std::numeric_limits<double>::max();
    double maxMs = 0;
    std::string message;
    for (int32_t index = 0; index < count; ++index) {
        auto start = Clock::now();
        OH_NN_ReturnCode code = CannModelRunner::GetInstance().RunOnce(message);
        double currentMs = ElapsedMs(start);
        if (code != OH_NN_SUCCESS) {
            napi_value failed = CreateResult(env, false, message, totalMs);
            SetNumber(env, failed, "count", index);
            SetNumber(env, failed, "totalMs", totalMs);
            SetNumber(env, failed, "averageMs", index == 0 ? 0 : totalMs / index);
            SetNumber(env, failed, "minMs", index == 0 ? 0 : minMs);
            SetNumber(env, failed, "maxMs", maxMs);
            return failed;
        }
        totalMs += currentMs;
        minMs = std::min(minMs, currentMs);
        maxMs = std::max(maxMs, currentMs);
    }

    napi_value result = CreateResult(env, true, "推理完成", totalMs);
    SetNumber(env, result, "count", count);
    SetNumber(env, result, "totalMs", totalMs);
    SetNumber(env, result, "averageMs", totalMs / count);
    SetNumber(env, result, "minMs", minMs);
    SetNumber(env, result, "maxMs", maxMs);
    return result;
}

napi_value Unload(napi_env env, napi_callback_info info)
{
    auto start = Clock::now();
    CannModelRunner::GetInstance().Unload();
    return CreateResult(env, true, "模型已卸载", ElapsedMs(start));
}
}

EXTERN_C_START
static napi_value Init(napi_env env, napi_value exports)
{
    napi_property_descriptor descriptors[] = {
        {"initialize", nullptr, Initialize, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"loadModel", nullptr, LoadModel, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"run", nullptr, Run, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"unload", nullptr, Unload, nullptr, nullptr, nullptr, napi_default, nullptr}
    };
    napi_define_properties(env, exports, sizeof(descriptors) / sizeof(descriptors[0]), descriptors);
    return exports;
}
EXTERN_C_END

static napi_module cannKitCostModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "cannkit_cost",
    .nm_priv = nullptr,
    .reserved = {0}
};

extern "C" __attribute__((constructor)) void RegisterCannKitCostModule()
{
    napi_module_register(&cannKitCostModule);
}
