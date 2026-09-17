export class ModelConfig {
  id: string;
  name: string;
  file: string;

  constructor(id: string, name: string, file: string) {
    this.id = id;
    this.name = name;
    this.file = file;
  }
}

export class BenchmarkResult {
  success: boolean = false;
  message: string = '';
  durationMs: number = 0;
}

export class LoadResult extends BenchmarkResult {
  inputCount: number = 0;
  outputCount: number = 0;
}

export class RunResult extends BenchmarkResult {
  count: number = 0;
  totalMs: number = 0;
  averageMs: number = 0;
  minMs: number = 0;
  maxMs: number = 0;
}

export class ModelTestResult {
  id: string = '';
  name: string = '';
  success: boolean = false;
  message: string = '';
  loadMs: number = 0;
  runCount: number = 0;
  totalMs: number = 0;
  averageMs: number = 0;
  minMs: number = 0;
  maxMs: number = 0;
}

export class BatchReport {
  generatedAt: string = '';
  repeatCount: number = 0;
  modelCount: number = 0;
  results: ModelTestResult[] = [];
}

export const MODEL_CONFIGS: ModelConfig[] = [
  new ModelConfig('alexnet', 'AlexNet', 'models/alexnet.om'),
  new ModelConfig('deeplabv3', 'DeepLabV3', 'models/deeplabv3.om'),
  new ModelConfig('fsr', 'FSR', 'models/fsr.om'),
  new ModelConfig('googlenet', 'GoogLeNet', 'models/googlenet.om'),
  new ModelConfig('inception_v3', 'Inception V3', 'models/inception_v3.om'),
  new ModelConfig('mobilenet_v1', 'MobileNet V1', 'models/mobilenet_v1.om'),
  new ModelConfig('mobilenet_v2', 'MobileNet V2', 'models/mobilenet_v2.om'),
  new ModelConfig('mobilenet_v2_1_4', 'MobileNet V2 1.4', 'models/mobilenet_v2_1_4.om'),
  new ModelConfig('mobilenet_v2_ssd', 'MobileNet V2 SSD', 'models/mobilenet_v2_ssd.om'),
  new ModelConfig('mobilenet_v3', 'MobileNet V3 Large', 'models/mobilenet_v3.om'),
  new ModelConfig('resnet18', 'ResNet-18', 'models/resnet18.om'),
  new ModelConfig('resnet50', 'ResNet-50', 'models/resnet50.om'),
  new ModelConfig('squeezenet_v1', 'SqueezeNet V1', 'models/squeezenet_v1.om'),
  new ModelConfig('vdsr', 'VDSR', 'models/vdsr.om'),
  new ModelConfig('yolov5', 'YOLOv5', 'models/yolov5.om')
];
