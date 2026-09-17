import { resourceManager } from '@kit.LocalizationKit';
import nativeBridge from 'libcannkit_cost.so';
import { BenchmarkResult, LoadResult, RunResult } from '../model/BenchmarkModels';

export class CannBenchmarkService {
  static initialize(): BenchmarkResult {
    return nativeBridge.initialize();
  }

  static loadModel(manager: resourceManager.ResourceManager, modelPath: string): LoadResult {
    return nativeBridge.loadModel(manager, modelPath);
  }

  static run(count: number): RunResult {
    return nativeBridge.run(count);
  }

  static unload(): BenchmarkResult {
    return nativeBridge.unload();
  }
}
