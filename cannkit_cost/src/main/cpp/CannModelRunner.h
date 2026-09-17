#ifndef CANN_MODEL_RUNNER_H
#define CANN_MODEL_RUNNER_H

#include "neural_network_runtime/neural_network_core.h"

#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

class CannModelRunner {
public:
    static CannModelRunner &GetInstance();

    CannModelRunner(const CannModelRunner &) = delete;
    CannModelRunner &operator=(const CannModelRunner &) = delete;

    OH_NN_ReturnCode Initialize(std::string &message);
    OH_NN_ReturnCode Load(const uint8_t *modelData, size_t modelSize, std::string &message);
    OH_NN_ReturnCode RunOnce(std::string &message);
    void Unload();

    size_t GetInputCount() const;
    size_t GetOutputCount() const;

private:
    CannModelRunner() = default;
    ~CannModelRunner();

    OH_NN_ReturnCode CreateTensors(std::string &message);
    static void DestroyTensors(std::vector<NN_Tensor *> &tensors);

    bool initialized_ {false};
    size_t deviceId_ {0};
    OH_NNExecutor *executor_ {nullptr};
    std::vector<NN_Tensor *> inputTensors_;
    std::vector<NN_Tensor *> outputTensors_;
};

#endif
