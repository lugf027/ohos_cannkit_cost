import { MODEL_CONFIGS, ModelConfig } from '../model/BenchmarkModels';

@Component
export struct ModelListPage {
  onBack: () => void = () => {};
  onSelect: (model: ModelConfig) => void = () => {};

  build() {
    Column() {
      Row() {
        Button('返回')
          .type(ButtonType.Normal)
          .onClick(() => this.onBack())
        Text('模型详情测试')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ left: 16 })
      }
      .width('100%')
      .height(64)
      .padding({ left: 16, right: 16 })

      List({ space: 10 }) {
        ForEach(MODEL_CONFIGS, (model: ModelConfig) => {
          ListItem() {
            Row() {
              Column() {
                Text(model.name)
                  .fontSize(18)
                  .fontWeight(FontWeight.Medium)
                Text(model.file)
                  .fontSize(12)
                  .fontColor('#7A7A7A')
                  .margin({ top: 4 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              Text('测试 >')
                .fontSize(15)
                .fontColor('#0A59F7')
            }
            .width('100%')
            .padding(16)
            .backgroundColor('#FFFFFF')
            .borderRadius(12)
            .onClick(() => this.onSelect(model))
          }
        }, (model: ModelConfig) => model.id)
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
