import { BatchTestPage, ModelConfig, ModelDetailPage, ModelListPage,
  MODEL_CONFIGS } from 'cannkit_cost';

const PAGE_HOME: string = 'home';
const PAGE_LIST: string = 'modelList';
const PAGE_DETAIL: string = 'modelDetail';
const PAGE_BATCH: string = 'batchTest';

@Entry
@Component
struct Index {
  @State currentPage: string = PAGE_HOME;
  @State selectedModel: ModelConfig = MODEL_CONFIGS[0];

  private openDetail(model: ModelConfig): void {
    this.selectedModel = model;
    this.currentPage = PAGE_DETAIL;
  }

  @Builder
  private homePage() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('CANN Kit 性能测试')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
        Text('在端侧运行 Model Zoo 模型，测量加载与推理耗时')
          .fontSize(15)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
      }
      .margin({ bottom: 24 })

      Column({ space: 8 }) {
        Text('详情测试')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
        Text('选择一个模型，分别执行初始化、加载和指定次数推理')
          .fontSize(14)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
        Button('进入模型列表')
          .width('100%')
          .margin({ top: 10 })
          .onClick(() => this.currentPage = PAGE_LIST)
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)

      Column({ space: 8 }) {
        Text('批量测试')
          .fontSize(22)
          .fontWeight(FontWeight.Medium)
        Text('依次运行全部模型，实时查看进度并分享 JSON 报告')
          .fontSize(14)
          .fontColor('#666666')
          .textAlign(TextAlign.Center)
        Button('进入批量测试')
          .width('100%')
          .margin({ top: 10 })
          .onClick(() => this.currentPage = PAGE_BATCH)
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(16)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#F5F7FA')
  }

  build() {
    Stack() {
      if (this.currentPage === PAGE_HOME) {
        this.homePage()
      } else if (this.currentPage === PAGE_LIST) {
        ModelListPage({
          onBack: () => this.currentPage = PAGE_HOME,
          onSelect: (model: ModelConfig) => this.openDetail(model)
        })
      } else if (this.currentPage === PAGE_DETAIL) {
        ModelDetailPage({
          model: this.selectedModel,
          onBack: () => this.currentPage = PAGE_LIST
        })
      } else {
        BatchTestPage({
          onBack: () => this.currentPage = PAGE_HOME
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
