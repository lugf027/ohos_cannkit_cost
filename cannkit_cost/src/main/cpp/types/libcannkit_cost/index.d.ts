import { resourceManager } from '@kit.LocalizationKit';

export interface NativeResult {
  success: boolean;
  message: string;
  durationMs: number;
}

export interface LoadResult extends NativeResult {
  inputCount: number;
  outputCount: number;
}

export interface RunResult extends NativeResult {
  count: number;
  totalMs: number;
  averageMs: number;
  minMs: number;
  maxMs: number;
}

export const initialize: () => NativeResult;
export const loadModel: (resourceManager: resourceManager.ResourceManager,
  modelPath: string) => LoadResult;
export const run: (count: number) => RunResult;
export const unload: () => NativeResult;
