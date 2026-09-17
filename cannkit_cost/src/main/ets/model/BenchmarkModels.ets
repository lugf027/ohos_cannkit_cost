export class ModelConfig {
  id: string;
  name: string;
  file: string;
  quantized: boolean;

  constructor(id: string, name: string, file: string, quantized: boolean = false) {
    this.id = id;
    this.name = name;
    this.file = file;
    this.quantized = quantized;
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
  new ModelConfig('alexnet_quant8_8', 'AlexNet (Quant8)', 'models/alexnet_quant8_8.om', true),
  new ModelConfig('deeplabv3', 'DeepLabV3', 'models/deeplabv3.om'),
  new ModelConfig('deeplabv3_quant8_8', 'DeepLabV3 (Quant8)', 'models/deeplabv3_quant8_8.om', true),
  new ModelConfig('fsr', 'FSR', 'models/fsr.om'),
  new ModelConfig('fsr_quant8_8', 'FSR (Quant8)', 'models/fsr_quant8_8.om', true),
  new ModelConfig('googlenet', 'GoogLeNet', 'models/googlenet.om'),
  new ModelConfig('googlenet_quant8_8', 'GoogLeNet (Quant8)', 'models/googlenet_quant8_8.om', true),
  new ModelConfig('inception_v3', 'Inception V3', 'models/inception_v3.om'),
  new ModelConfig('inception_v3_quant8_8', 'Inception V3 (Quant8)',
    'models/inception_v3_quant8_8.om', true),
  new ModelConfig('mobilenet_v1', 'MobileNet V1', 'models/mobilenet_v1.om'),
  new ModelConfig('mobilenet_v1_quant8_8', 'MobileNet V1 (Quant8)',
    'models/mobilenet_v1_quant8_8.om', true),
  new ModelConfig('mobilenet_v2', 'MobileNet V2', 'models/mobilenet_v2.om'),
  new ModelConfig('mobilenet_v2_quant8_8', 'MobileNet V2 (Quant8)',
    'models/mobilenet_v2_quant8_8.om', true),
  new ModelConfig('mobilenet_v2_1_4', 'MobileNet V2 1.4', 'models/mobilenet_v2_1_4.om'),
  new ModelConfig('mobilenet_v2_1_4_quant8_8', 'MobileNet V2 1.4 (Quant8)',
    'models/mobilenet_v2_1_4_quant8_8.om', true),
  new ModelConfig('mobilenet_v2_ssd', 'MobileNet V2 SSD', 'models/mobilenet_v2_ssd.om'),
  new ModelConfig('mobilenet_v2_ssd_quant8_8', 'MobileNet V2 SSD (Quant8)',
    'models/mobilenet_v2_ssd_quant8_8.om', true),
  new ModelConfig('mobilenet_v3', 'MobileNet V3 Large', 'models/mobilenet_v3.om'),
  new ModelConfig('mobilenet_v3_quant8_8', 'MobileNet V3 Large (Quant8)',
    'models/mobilenet_v3_quant8_8.om', true),
  new ModelConfig('resnet18', 'ResNet-18', 'models/resnet18.om'),
  new ModelConfig('resnet18_quant8_8', 'ResNet-18 (Quant8)', 'models/resnet18_quant8_8.om', true),
  new ModelConfig('resnet50', 'ResNet-50', 'models/resnet50.om'),
  new ModelConfig('resnet50_quant8_8', 'ResNet-50 (Quant8)', 'models/resnet50_quant8_8.om', true),
  new ModelConfig('squeezenet_v1', 'SqueezeNet V1', 'models/squeezenet_v1.om'),
  new ModelConfig('squeezenet_v1_quant8_8', 'SqueezeNet V1 (Quant8)',
    'models/squeezenet_v1_quant8_8.om', true),
  new ModelConfig('vdsr', 'VDSR', 'models/vdsr.om'),
  new ModelConfig('vdsr_quant8_8', 'VDSR (Quant8)', 'models/vdsr_quant8_8.om', true),
  new ModelConfig('yolov5', 'YOLOv5', 'models/yolov5.om'),
  new ModelConfig('yolov5_quant8_8', 'YOLOv5 (Quant8)', 'models/yolov5_quant8_8.om', true)
];
