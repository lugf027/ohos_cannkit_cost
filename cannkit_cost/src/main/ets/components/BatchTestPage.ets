import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { uniformTypeDescriptor as utd } from '@kit.ArkData';
import { systemShare } from '@kit.ShareKit';
import { BatchReport, BenchmarkResult, LoadResult, MODEL_CONFIGS, ModelConfig,
  ModelTestResult, RunResult } from '../model/BenchmarkModels';
import { CannBenchmarkService } from '../service/CannBenchmarkService';

@Component
export struct BatchTestPage {
  onBack: () => void = () => {};

  @State repeatText: string = '10';
  @State running: boolean = false;
  @State progress: number = 0;
  @State currentModel: string = '尚未开始';
  @State results: ModelTestResult[] = [];
  @State message: string = '';

  aboutToDisappear(): void {
    CannBenchmarkService.unload();
  }

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private async yieldForRender(): Promise<void> {
    await new Promise<void>((resolve: () => void) => {
      setTimeout(resolve, 0);
    });
  }

  private async startBatch(): Promise<void> {
    const count: number = Number.parseInt(this.repeatText);
    if (!Number.isInteger(count) || count < 1 || count > 10000) {
      this.message = '运行次数必须是 1 到 10000 的整数';
      return;
    }

    this.running = true;
    this.progress = 0;
    this.results = [];
    this.message = '';
    const initResult: BenchmarkResult = CannBenchmarkService.initialize();
    if (!initResult.success) {
      this.message = initResult.message;
      this.running = false;
      return;
    }

    for (let index: number = 0; index < MODEL_CONFIGS.length; ++index) {
      const model: ModelConfig = MODEL_CONFIGS[index];
      this.currentModel = model.name;
      await this.yieldForRender();

      const item: ModelTestResult = new ModelTestResult();
      item.id = model.id;
      item.name = model.name;
      item.runCount = count;
      const loadResult: LoadResult =
        CannBenchmarkService.loadModel(this.getContext().resourceManager, model.file);
      item.loadMs = loadResult.durationMs;
      if (loadResult.success) {
        const runResult: RunResult = CannBenchmarkService.run(count);
        item.success = runResult.success;
        item.message = runResult.message;
        item.totalMs = runResult.totalMs;
        item.averageMs = runResult.averageMs;
        item.minMs = runResult.minMs;
        item.maxMs = runResult.maxMs;
      } else {
        item.success = false;
        item.message = loadResult.message;
      }
      CannBenchmarkService.unload();
      this.results = this.results.concat(item);
      this.progress = (index + 1) * 100 / MODEL_CONFIGS.length;
      await this.yieldForRender();
    }
    this.currentModel = '全部完成';
    this.message = `已完成 ${this.results.length} 个模型的测试`;
    this.running = false;
  }

  private async shareResult(): Promise<void> {
    if (this.results.length === 0 || this.running) {
      this.message = '请先完成批量测试';
      return;
    }
    const report: BatchReport = new BatchReport();
    report.generatedAt = new Date().toISOString();
    report.repeatCount = Number.parseInt(this.repeatText);
    report.modelCount = this.results.length;
    report.results = this.results;

    const context: common.UIAbilityContext = this.getContext();
    const path: string = `${context.filesDir}/cannkit_benchmark_${Date.now()}.json`;
    try {
      const file: fs.File = fs.openSync(path,
        fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE | fs.OpenMode.TRUNC);
      fs.writeSync(file.fd, JSON.stringify(report, null, 2));
      fs.closeSync(file);

      const typeId: string =
        utd.getUniformDataTypeByFilenameExtension('.json', utd.UniformDataType.PLAIN_TEXT);
      const shareData: systemShare.SharedData = new systemShare.SharedData({
        utd: typeId,
        uri: fileUri.getUriFromPath(path),
        title: 'CANN Kit 模型推理测试结果',
        description: 'CANN Kit 批量模型推理耗时 JSON'
      });
      const controller: systemShare.ShareController = new systemShare.ShareController(shareData);
      await controller.show(context, {
        selectionMode: systemShare.SelectionMode.SINGLE,
        previewMode: systemShare.SharePreviewMode.DETAIL
      });
      this.message = '已打开分享面板';
    } catch (error) {
      const businessError: BusinessError = error as BusinessError;
      this.message = `分享失败: ${businessError.message}`;
    }
  }

  @Builder
  private resultCard(item: ModelTestResult) {
    Column({ space: 5 }) {
      Row() {
        Text(item.name)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
        Text(item.success ? '成功' : '失败')
          .fontSize(14)
          .fontColor(item.success ? '#16823B' : '#C53B32')
      }
      .width('100%')
      if (item.success) {
        Text(`加载 ${item.loadMs.toFixed(3)} ms | 平均 ${item.averageMs.toFixed(3)} ms`)
          .fontSize(13)
          .fontColor('#555555')
      } else {
        Text(item.message)
          .fontSize(13)
          .fontColor('#C53B32')
      }
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .type(ButtonType.Normal)
          .enabled(!this.running)
          .onClick(() => this.onBack())
        Text('批量测试')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })

      Column({ space: 12 }) {
        Row({ space: 10 }) {
          TextInput({ text: this.repeatText, placeholder: '每个模型运行次数' })
            .type(InputType.Number)
            .layoutWeight(1)
            .enabled(!this.running)
            .onChange((value: string) => this.repeatText = value)
          Button('开始')
            .enabled(!this.running)
            .onClick(() => this.startBatch())
        }
        .width('100%')

        Progress({ value: this.progress, total: 100, type: ProgressType.Linear })
          .width('100%')
        Text(`进度 ${this.progress.toFixed(0)}% | ${this.currentModel}`)
          .fontSize(14)
          .fontColor('#555555')
          .width('100%')

        if (this.message.length > 0) {
          Text(this.message)
            .fontSize(14)
            .width('100%')
        }

        List({ space: 8 }) {
          ForEach(this.results, (item: ModelTestResult) => {
            ListItem() {
              this.resultCard(item)
            }
          }, (item: ModelTestResult) => item.id)
        }
        .layoutWeight(1)
        .width('100%')

        Button('分享 JSON 结果')
          .width('100%')
          .enabled(!this.running && this.results.length > 0)
          .onClick(() => this.shareResult())
      }
      .layoutWeight(1)
      .width('100%')
      .padding({ left: 16, right: 16, bottom: 16 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
