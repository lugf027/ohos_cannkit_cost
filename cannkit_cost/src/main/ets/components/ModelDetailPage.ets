import { common } from '@kit.AbilityKit';
import { CannBenchmarkService } from '../service/CannBenchmarkService';
import { BenchmarkResult, LoadResult, ModelConfig, RunResult } from '../model/BenchmarkModels';

@Component
export struct ModelDetailPage {
  model: ModelConfig = new ModelConfig('', '', '');
  onBack: () => void = () => {};

  @State repeatText: string = '10';
  @State status: string = '等待初始化';
  @State initialized: boolean = false;
  @State loaded: boolean = false;
  @State busy: boolean = false;

  aboutToDisappear(): void {
    CannBenchmarkService.unload();
  }

  private getContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private initialize(): void {
    this.busy = true;
    const result: BenchmarkResult = CannBenchmarkService.initialize();
    this.initialized = result.success;
    this.status = `${result.message}\n初始化耗时: ${result.durationMs.toFixed(3)} ms`;
    this.busy = false;
  }

  private load(): void {
    this.busy = true;
    const result: LoadResult =
      CannBenchmarkService.loadModel(this.getContext().resourceManager, this.model.file);
    this.loaded = result.success;
    this.status = `${result.message}\n加载耗时: ${result.durationMs.toFixed(3)} ms` +
      `\n输入 Tensor: ${result.inputCount}，输出 Tensor: ${result.outputCount}`;
    this.busy = false;
  }

  private run(count: number): void {
    if (!this.loaded) {
      this.status = '请先加载模型';
      return;
    }
    this.busy = true;
    const result: RunResult = CannBenchmarkService.run(count);
    this.status = result.success ?
      `运行 ${result.count} 次完成\n总耗时: ${result.totalMs.toFixed(3)} ms` +
        `\n平均: ${result.averageMs.toFixed(3)} ms` +
        `\n最小: ${result.minMs.toFixed(3)} ms，最大: ${result.maxMs.toFixed(3)} ms` :
      result.message;
    this.busy = false;
  }

  private runRepeated(): void {
    const count: number = Number.parseInt(this.repeatText);
    if (!Number.isInteger(count) || count < 1 || count > 10000) {
      this.status = '运行次数必须是 1 到 10000 的整数';
      return;
    }
    this.run(count);
  }

  build() {
    Column() {
      Row() {
        Button('返回')
          .type(ButtonType.Normal)
          .enabled(!this.busy)
          .onClick(() => this.onBack())
        Text(this.model.name)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })

      Scroll() {
        Column({ space: 14 }) {
          Column({ space: 6 }) {
            Text('模型文件')
              .fontSize(14)
              .fontColor('#666666')
            Text(this.model.file)
              .fontSize(16)
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          Row({ space: 10 }) {
            Button('初始化')
              .layoutWeight(1)
              .enabled(!this.busy)
              .onClick(() => this.initialize())
            Button('加载模型')
              .layoutWeight(1)
              .enabled(!this.busy)
              .onClick(() => this.load())
          }
          .width('100%')

          Button('运行一次')
            .width('100%')
            .enabled(!this.busy && this.loaded)
            .onClick(() => this.run(1))

          Row({ space: 10 }) {
            TextInput({ text: this.repeatText, placeholder: '运行次数' })
              .type(InputType.Number)
              .layoutWeight(1)
              .onChange((value: string) => this.repeatText = value)
            Button('运行指定次数')
              .enabled(!this.busy && this.loaded)
              .onClick(() => this.runRepeated())
          }
          .width('100%')

          Column() {
            Text('测试结果')
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
            Text(this.status)
              .fontSize(15)
              .lineHeight(24)
              .fontColor('#333333')
              .margin({ top: 10 })
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding(16)
          .backgroundColor('#FFFFFF')
          .borderRadius(12)

          if (this.busy) {
            Row({ space: 10 }) {
              LoadingProgress()
                .width(24)
                .height(24)
              Text('处理中，请稍候')
            }
          }
        }
        .width('100%')
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F7FA')
  }
}
