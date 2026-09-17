代码地址：https://github.com/lugf027/ohos_cannkit_cost

### 克隆/拉取说明

本仓库使用 Git LFS 存储 OM 模型文件（`entry/src/main/resources/rawfile/models/*.om`），克隆前请先确保已安装 Git LFS：

```bash
# 安装 Git LFS（如未安装）
brew install git-lfs   # macOS
# 或参考 https://git-lfs.com 安装其他平台版本

# 初始化（每台机器只需一次）
git lfs install

# 克隆（含 LFS 对象）
git clone git@github.com:lugf027/ohos_cannkit_cost.git

# 若已克隆但未拉取 LFS 对象，执行以下命令补全
git lfs pull
```

* 运行正确的日志: docs/logs_achieve/mate70pro_ok_0917-1107.log
* 运行出错的日志: docs/logs_achieve/nova14_fail_0917-1103.log


![nova14运行出错](docs/images/img.png)

