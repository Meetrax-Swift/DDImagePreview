// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import Kingfisher
import Photos
public struct DDImagePreview<CustomView: View>: View {
    
    /// 是否显示弹窗
    @Binding var isPresented: Bool
    /// 数据源
    var sources: [DDImageSource]
    /// 基本配置文件
    var config: DDImagePreviewConfig
    /// 可选的自定义指示器
    var custom: ((_ current: Int) -> CustomView)?
    
    @State private var currentIndex: Int = 0
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    /// 显示保存Sheet
    @State private var showSaveSheet = false
    /// 是否显示保存成功的提示
    @State private var showToast = false
    /// 保存弹窗的提示语
    @State private var saveToastMessage = ""
    /// 当放大图片的时候是否显示只是器
    @State private var isShowIndicator: Bool = false
    /// 新增：用于控制透明度的状态
    @State private var opacity: Double = 1.0
    /// 底部Sheet每个item的高度
    private let sheetItemHeight: CGFloat = 45.0
    /// 指示器偏移大小
    private var indicatorOffset: CGFloat {
        var offset = config.indicator.offset
        if config.ignoreSafeArea {
            switch config.indicator.position {
            case .top:
                offset += DDSafeArea.top
            case .bottom:
                offset += DDSafeArea.bottom
            }
        }
        return offset
    }
    
    // 主要初始化器（私有）
    private init(
        _internal isPresented: Binding<Bool>,
        sources: [DDImageSource],
        initialIndex: Int,
        config: DDImagePreviewConfig,
        custom: ((_ current: Int) -> CustomView)?
    ) {
        self._isPresented = isPresented
        self.sources = sources
        self._currentIndex = State(
            initialValue: min(initialIndex, max(0, sources.count - 1))
        )
        self.config = config
        self.custom = custom
        self._isShowIndicator = State(initialValue: config.indicator.show)
        
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack() {
                // 背景层
                config.backgroundColor
                    .ignoresSafeArea()
                    .onTapGesture(count: 1) {
                        handleSingleTap()
                    }
                
                // 图片预览
                TabView(selection: $currentIndex) {
                    ForEach(0..<sources.count, id: \.self) { index in
                        DDZoomableImageView(
                            source: sources[index],
                            ignoreSafeArea: config.ignoreSafeArea,
                            placeholder: config.placehoderImage,
                            errorPlaceholder: config.errorPlaceholderImage,
                            geometry: geometry,
                            scale: $scale,
                            lastScale: $lastScale,
                            offset: $offset,
                            lastOffset: $lastOffset,
                            maxScale: config.maxScale,
                            minScale: config.minScale,
                            doubleTapScale: config.doubleTapScale,
                            showLoadingProgress: config.showLoadingProgress,
                            onDoubleTap: handleDoubleTap,
                            onSingleTap: handleSingleTap,
                            onDragChange: handleDragChange,
                            onDragEnd: handleDragEnd)
                        .tag(index)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .onChange(of: isShowIndicator) {newValue in
                            withAnimation {
                                opacity = newValue ? 1 : 0
                            }
                        }
                    }
                }
                .background(config.backgroundColor)
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    handleSingleTap()
                }
                
                // 这个是自定的视图 可以传入任何视图
                if let custom = custom {
                    custom(currentIndex)
                        .opacity(config.isShowCustomViewWhenZoom ? 1 : opacity)
                }
                
                // 这是指示器视图
                if config.indicator.show && sources.count > 1 {
                    indicatorView
                        .opacity(opacity)
                }
                
                if config.isCanSave {
                    ZStack {
                        Button {
                            saveCurrentImage()
                        } label: {
                            Image("save", bundle: .module)
                        }
                        .padding(.trailing, 10)
                        .padding(.top, DDSafeArea.top + 10)
                    }
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }
                
                // 提示弹窗
                if showToast {
                    saveToastView
                }
            }
            .onLongPressGesture {
                showSaveSheet = config.isCanSave
            }
        }
        .sheet(isPresented: $showSaveSheet, content: {
            saveActionSheet
                .presentationDetents([.height(sheetItemHeight * 2 + 15)])
                // 2. 显示拖拽指示器
                .presentationDragIndicator(.hidden) // 或 .hidden
                .background(.white)
//                // 3. 设置圆角 （iOS 16.4+）
//                .presentationCornerRadius(20)
//                // 4. 背景交互 （iOS 16.4+）
//                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
//                // 5. 背景色（iOS 16.4+）
//                .presentationBackground(
//                    Color.white // 或 Color, ShapeStyle
//                )
            
        })
        .onChange(of: currentIndex) {newValue in
            resetZoomState()
        }
    }
}
// MARK: - 子试图
extension DDImagePreview {
    // 指示器控件
    private var indicatorView: some View {
        VStack() {
            if config.indicator.position == .bottom {
                Spacer()
            }
            DDPreviewPageIndicator(
                currentIndex: currentIndex,
                totalCount: sources.count,
                color: config.indicator.color,
                normalIndicatorColor: config.indicator.normalIndicatorColor,
                backgroundColor: config.indicator.backgroundColor,
                style: config.indicator.style
            )
            .padding(config.indicator.position == .bottom ? .bottom : .top, indicatorOffset)
            
            if config.indicator.position == .top {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
    
    // 保存图片弹窗提示
    private var saveToastView: some View {
        VStack {
            HStack(spacing: 8) {
                Text(saveToastMessage)
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.8))
            .cornerRadius(8)
            .padding(.bottom, 100)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .allowsHitTesting(false)
    }
    private var saveActionSheet: some View {
        VStack(spacing: 0) {
        
            // 保存按钮
            Button {
                showSaveSheet = false
                saveCurrentImage()
            } label: {
                Text("保存到相册")
                    .font(.system(size: 15))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, minHeight: sheetItemHeight)
            }
            
            
            Divider()
            
            // 取消按钮
            Button {
                showSaveSheet = false
            } label: {
                Text("取消")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, minHeight: sheetItemHeight)
            }
        }
        .padding(.top, 15)
    }
}
//MARK: - 初始化方法
extension DDImagePreview where CustomView == EmptyView {
    // 没有自定义指示器的初始化器
    public init(
        isPresented: Binding<Bool>,
        sources: [DDImageSource],
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default
    ) {
        self.init(
            _internal: isPresented,
            sources: sources,
            initialIndex: initialIndex,
            config: config,
            custom: nil
        )
    }
}

extension DDImagePreview {
    // 带有自定义指示器的初始化器
    public init(
        isPresented: Binding<Bool>,
        sources: [DDImageSource],
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default,
        @ViewBuilder custom: @escaping (_ current: Int) -> CustomView
    ) {
        self.init(
            _internal: isPresented,
            sources: sources,
            initialIndex: initialIndex,
            config: config,
            custom: custom
        )
    }
}
//MARK: - 点击事件
extension DDImagePreview {
    // 单击事件
    private func handleSingleTap() {
        isPresented = false
    }
    
    // 双击事件
    private func handleDoubleTap() {
        withAnimation(.spring()) {
            if scale > config.minScale {
                resetZoomState()
            } else {
                scale = config.doubleTapScale
                lastScale = config.minScale
            }
            handleShowIndicator()
        }
    }
    
    // 拖拽进行中
    private func handleDragChange() {
        // 空实现，保持接口兼容
        handleShowIndicator()
    }
    
    // 拖拽结束
    private func handleDragEnd() {
        if scale > config.minScale {
            lastOffset = offset
        }
    }
    
    // 处理放大的时候隐藏掉只是器
    private func handleShowIndicator() {
        // 放大的时候隐藏指示器
        if config.indicator.show {
            isShowIndicator = scale <= config.minScale
        }
    }
    
    // 重置试图
    private func resetZoomState() {
        withAnimation(.spring()) {
            scale = config.minScale
            lastScale = config.minScale
            offset = .zero
            lastOffset = .zero
        }
    }
}
//MARK: - 保存图片相关
extension DDImagePreview {
    private func saveCurrentImage() {
        guard currentIndex < sources.count else { return }
        
        let source = sources[currentIndex]
        
        switch source {
        case .remote(let url, _, _):
            saveRemoteImage(url: url)
        case .local(let localSource):
            saveLocalImage(localSource: localSource)
        }
    }
    
    private func saveRemoteImage(url: String) {
        guard let imageUrl = URL(string: url) else {
            onShowToast("图片地址无效")
            return
        }
        
        // 显示加载状态
        saveToastMessage = "正在保存..."
        showToast = true
        
        // 使用 Kingfisher 下载图片
        KingfisherManager.shared.retrieveImage(with: imageUrl) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let value):
                    saveUIImageToPhotos(value.image)
                case .failure(let error):
                    onShowToast("下载失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func saveLocalImage(localSource: DDImageSource.LocalImageSource) {
        if let image = localSource.image {
            // UIImage
            saveUIImageToPhotos(image)
        } else if let assetName = localSource.assetName {
            // Asset 图片
            if let image = UIImage(named: assetName) {
                saveUIImageToPhotos(image)
            } else if let image = UIImage(systemName: assetName) {
                // 系统图标
                let renderer = UIGraphicsImageRenderer(size: image.size)
                let coloredImage = renderer.image { context in
                    UIColor.white.setFill()
                    context.fill(CGRect(origin: .zero, size: image.size))
                    image.withTintColor(.black).draw(in: CGRect(origin: .zero, size: image.size))
                }
                saveUIImageToPhotos(coloredImage)
            } else {
                onShowToast("本地图片加载失败")
            }
        } else if let fileURL = localSource.fileURL {
            // 本地文件（支持 GIF）
            if let data = try? Data(contentsOf: fileURL),
               let image = UIImage(data: data) {
                saveUIImageToPhotos(image)
            } else {
                onShowToast("文件加载失败")
            }
        } else {
            onShowToast("图片资源不可用")
        }
    }
    
    private func saveUIImageToPhotos(_ image: UIImage) {
        // 检查相册权限
        checkPhotoLibraryPermission { hasPermission in
            guard hasPermission else {
                onShowToast("请开启相册权限")
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            onShowToast("图片已保存到相册")
        }
    }
    
    private func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }
    
    private func onShowToast(_ message: String) {
        saveToastMessage = message
        showToast = true
        // 2秒后自动隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

//MARK: - 安全区域
struct DDSafeArea {
    static var insets: UIEdgeInsets {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window?.safeAreaInsets ?? .zero
    }
    
    static var top: CGFloat { insets.top }
    static var bottom: CGFloat { insets.bottom }
    static var left: CGFloat { insets.left }
    static var right: CGFloat { insets.right }
}
