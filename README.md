# DDImagePreview

一个轻量级、功能强大的 SwiftUI 图片预览库，基于 **Kingfisher** 实现远程图片缓存和加载，支持远程图片、本地图片、GIF 动图预览，提供流畅的缩放交互体验。

## 功能特性

- ✅ 基于 **Kingfisher** 实现远程图片缓存和加载
- ✅ 支持远程图片 URL 预览（自动缓存、失败重试）
- ✅ 支持本地图片（UIImage、Asset、文件路径）
- ✅ 支持 GIF 动图预览（使用 KFAnimatedImage）
- ✅ 流畅的手势缩放（双指捏合、双击放大）
- ✅ 图片保存到相册功能
- ✅ 自定义页码指示器（点状/文字样式）
- ✅ 自定义背景颜色
- ✅ 自定义占位图和错误占位图
- ✅ 九宫格网格展示视图
- ✅ 支持自定义视图注入

## 预览效果

<p align="center">
  <img src="https://github.com/user-attachments/assets/1c2469ba-8069-40b1-8d76-560cf28b5b57" width="300" alt="DDImagePreview Demo">
</p>

## 系统要求

- iOS 17.0+

## 通过 Swift Package Manager 导入

### 方法一：使用 Xcode 添加

1. 打开你的 Xcode 项目
2. 点击 `File` → `Add Packages...`
3. 在搜索框中输入：`https://github.com/Meetrax-Swift/DDImagePreview.git`
4. 选择最新版本，点击 `Add Package`
5. 在弹出的对话框中选择需要添加的目标

### 方法二：手动添加到 Package.swift

在你的 `Package.swift` 文件中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/Meetrax-Swift/DDImagePreview.git", from: "1.0.0")
]
```

然后在目标中添加：

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "DDImagePreview", package: "DDImagePreview")
    ]
)
```

## 快速开始

### 1. 基础使用（直接使用视图）

```swift
import SwiftUI
import DDImagePreview

struct ContentView: View {
    @State private var isPresented = false
    @State private var previewIndex: Int = 0
    let imageSources = [
        DDImageSource.url("https://example.com/image1.jpg"),
        DDImageSource.url("https://example.com/image2.jpg"),
        DDImageSource.url("https://example.com/image3.jpg")
    ]
    
    var body: some View {
        Button("预览图片") {
            isPresented = true
        }
        .ddImagePreview(isPresented: $isPresented, sources: imageSources, initialIndex: previewIndex)
    }
}
```

### 2. 使用管理器（推荐）

```swift
import SwiftUI
import DDImagePreview

struct ContentView: View {
    let imageSources = [
        DDImageSource.url("https://example.com/image1.jpg"),
        DDImageSource.url("https://example.com/image2.jpg")
    ]
    
    var body: some View {
        Button("预览图片") {
            DDImagePreviewManager.show(sources: imageSources, initialIndex: 0)
        }
    }
}

// 在 App 入口或主视图中添加预览容器
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .ddWithGlobalPreview()
        }
    }
}
```

### 3. 九宫格网格展示

```swift
import SwiftUI
import DDImagePreview

struct GridView: View {
    let imageSources = [
        DDImageSource.url("https://example.com/image1.jpg"),
        DDImageSource.url("https://example.com/image2.jpg"),
        DDImageSource.url("https://example.com/image3.jpg"),
        // ...更多图片
    ]
    
    var body: some View {
        DDGridImageView(
            sources: imageSources,
            columns: 3,
            spacing: 4
        ) { index in
            DDImagePreviewManager.show(sources: imageSources, initialIndex: index)
        }
    }
}
```

## 配置选项

### 自定义预览配置

```swift
let config = DDImagePreviewConfig(
    ignoreSafeArea: true,                    // 是否忽略安全区
    backgroundColor: .black,                 // 背景颜色
    isCanSave: true,                         // 是否允许保存到相册
    indicator: DDPageIndicatorConfig(
        show: true,                          // 是否显示指示器
        position: .bottom,                   // 指示器位置（.top / .bottom）
        style: .text,                        // 指示器样式（.dot / .text）
        offset: 20,                          // 偏移量
        color: .white,                       // 选中颜色
        normalIndicatorColor: .white.opacity(0.5),
        backgroundColor: .clear
    ),
    maxScale: 5.0,                          // 最大缩放比例
    doubleTapScale: 2.0,                    // 双击缩放比例
    minScale: 1.0,                          // 最小缩放比例
    showLoadingProgress: true,               // 是否显示加载进度
    placeholderImage: Image(systemName: "photo"),
    errorPlaceholderImage: Image(systemName: "exclamationmark.triangle"),
    isShowCustomViewWhenZoom: false          // 缩放时是否显示自定义视图
)

DDImagePreviewManager.show(sources: imageSources, config: config)
```

### 图片数据源类型

```swift
// 远程图片 URL
DDImageSource.url("https://example.com/image.jpg")
DDImageSource.url("https://example.com/image.jpg", placeholderImage: UIImage(named: "placeholder"))
DDImageSource.url("https://example.com/image.jpg", size: CGSize(width: 100, height: 100))

// 本地 UIImage
DDImageSource.image(UIImage(named: "myImage")!)

// Asset 图片
DDImageSource.asset("assetName")

// 本地文件（支持 GIF）
DDImageSource.localFile(URL(fileURLWithPath: "/path/to/image.gif"))
```

## 完整示例

```swift
import SwiftUI
import DDImagePreview

struct PhotoGalleryView: View {
    let images = [
        DDImageSource.url("https://picsum.photos/800/600?random=1"),
        DDImageSource.url("https://picsum.photos/800/600?random=2"),
        DDImageSource.url("https://picsum.photos/800/600?random=3"),
        DDImageSource.url("https://picsum.photos/800/600?random=4"),
        DDImageSource.url("https://picsum.photos/800/600?random=5"),
        DDImageSource.url("https://picsum.photos/800/600?random=6")
    ]
    
    var body: some View {
        NavigationStack {
            DDGridImageView(
                sources: images,
                columns: 3,
                spacing: 2
            ) { index in
                // 自定义配置
                let config = DDImagePreviewConfig(
                    isCanSave: true,
                    indicator: DDPageIndicatorConfig(
                        style: .dot,
                        position: .bottom,
                        offset: 30
                    )
                )
                DDImagePreviewManager.show(sources: images, initialIndex: index, config: config)
            }
            .navigationTitle("图片画廊")
        }
    }
}
```

## 注意事项

1. **相册权限**：如果启用了保存功能（`isCanSave: true`），需要在 `Info.plist` 中添加相册权限描述：
   - `NSPhotoLibraryAddUsageDescription` - 描述为什么需要访问相册

2. **Kingfisher 集成**：库内部使用 **Kingfisher 8.9.0+** 处理远程图片，包括：
   - 自动图片缓存（内存缓存 + 磁盘缓存）
   - 失败自动重试机制
   - GIF 动图解码和播放（使用 `KFAnimatedImage`）
   - 无需额外配置，依赖会自动通过 SPM 引入

3. **GIF 支持**：自动检测 `.gif` 扩展名的图片，使用 `KFAnimatedImage` 展示流畅的动画效果。

## License

DDImagePreview is available under the MIT license. See the LICENSE file for more info.