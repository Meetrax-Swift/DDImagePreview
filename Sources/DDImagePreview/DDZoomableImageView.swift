//
//  DDZoomableImageView.swift
//  DDImagePreview
//
//  Created by Meet on 2025/12/10.
//
import SwiftUI
import Kingfisher
struct DDZoomableImageView: View {
    let source: DDImageSource
    let ignoreSafeArea: Bool
    let placeholder: Image?
    let errorPlaceholder: Image?
    let geometry: GeometryProxy
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    @Binding var offset: CGSize
    @Binding var lastOffset: CGSize
    let maxScale: CGFloat
    let minScale: CGFloat
    let doubleTapScale: CGFloat
    let showLoadingProgress: Bool
    let onDoubleTap: () -> Void
    let onSingleTap: () -> Void
    let onDragChange: () -> Void
    let onDragEnd: () -> Void
    
    // 新增：存储图片实际尺寸
    @State private var imageOriginalSize: CGSize = .zero
    @State private var isLoading = false
    @State private var loadFailed = false
    @State private var loadProgress: Double = 0
    
    
    // MARK: - 初始化
    public init(
        source: DDImageSource,
        ignoreSafeArea: Bool,
        placeholder: Image?,
        errorPlaceholder: Image?,
        geometry: GeometryProxy,
        scale: Binding<CGFloat>,
        lastScale: Binding<CGFloat>,
        offset: Binding<CGSize>,
        lastOffset: Binding<CGSize>,
        maxScale: CGFloat,
        minScale: CGFloat,
        doubleTapScale: CGFloat,
        showLoadingProgress: Bool,
        onDoubleTap: @escaping () -> Void,
        onSingleTap: @escaping () -> Void,
        onDragChange: @escaping () -> Void,
        onDragEnd: @escaping () -> Void
    ) {
        self.source = source
        self.ignoreSafeArea = ignoreSafeArea
        self.placeholder = placeholder
        self.errorPlaceholder = errorPlaceholder
        self._scale = scale
        self._lastScale = lastScale
        self._offset = offset
        self._lastOffset = lastOffset
        self.geometry = geometry
        self.maxScale = maxScale
        self.minScale = minScale
        self.doubleTapScale = doubleTapScale
        self.showLoadingProgress = showLoadingProgress
        self.onDoubleTap = onDoubleTap
        self.onSingleTap = onSingleTap
        self.onDragChange = onDragChange
        self.onDragEnd = onDragEnd
    }
    
    
    var body: some View {
        ZStack {
            if loadFailed {
                errorView
            } else {
                mainImageView
                    .opacity(isLoading ? 0.3 : 1.0)
                if isLoading && showLoadingProgress {
                    loadingView
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadImage()
        }
    }
    
    
    
}
// MARK: - 子视图
extension DDZoomableImageView {
    private var mainImageView: some View {
        Group {
            if source.isGIF {
                gifImageView
            } else {
                normalImageView
            }
        }
    }
    
    // GIF 图片视图
    private var gifImageView: some View {
        Group {
            switch source {
            case .remote(let url, _, _):
                remoteGIFView(url)
            case .local(let localSource):
                localGIFView(localSource)
            }
        }
    }
    
    // 普通图片视图
    private var normalImageView: some View {
        Group {
            switch source {
            case .remote(let url, _, _):
                remoteNormalView(url)
            case .local(let localSource):
                localNormalView(localSource)
            }
        }
    }
    
    // 远程 GIF 视图
    private func remoteGIFView(_ urlString: String) -> some View {
        Group {
            if let url = URL(string: urlString) {
                KFAnimatedImage(url)
                    .placeholder {
                        placeholderView
                    }
                    .scaledToFit()
                    .gesture(singleTapGesture)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                errorView
            }
        }
    }
    
    // 本地 GIF 视图
    private func localGIFView(_ localSource: DDImageSource.LocalImageSource) -> some View {
        Group {
            if let url = localSource.fileURL {
                KFAnimatedImage(url)
                    .placeholder {
                        placeholderView
                    }
                    .scaledToFit()
                    .gesture(singleTapGesture)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                errorView
            }
        }
    }
    
    // 远程普通图片视图
    private func remoteNormalView(_ urlString: String) -> some View {
        Group {
            if let url = URL(string: urlString) {
                KFImage(url)
                    .placeholder {
                        placeholderView
                    }
                    .resizable()
                    .scaledToFit()
                    .offset(offset)
                    .scaleEffect(scale)
                    .gesture(ExclusiveGesture(doubleTapGesture, singleTapGesture))
                    .gesture(scale > minScale ? dragGesture : nil)
                    .gesture(magnificationGesture)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                errorView
            }
        }
    }
    
    // 本地普通图片视图
    private func localNormalView(_ localSource: DDImageSource.LocalImageSource) -> some View {
        Group {
            if let image = localSource.image {
                // UIImage
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .offset(offset)
                    .scaleEffect(scale)
                    .gesture(ExclusiveGesture(doubleTapGesture, singleTapGesture))
                    .gesture(scale > minScale ? dragGesture : nil)
                    .gesture(magnificationGesture)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let assetName = localSource.assetName {
                // Asset 图片
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .offset(offset)
                    .scaleEffect(scale)
                    .gesture(ExclusiveGesture(doubleTapGesture, singleTapGesture))
                    .gesture(scale > minScale ? dragGesture : nil)
                    .gesture(magnificationGesture)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                errorView
            }
        }
    }
    
    /// 占位图片
    private var placeholderView: some View {
        Group {
            // 首先尝试使用 source 的 placeholderImage
            if let placeholderImage = source.placeholderImage {
                Image(uiImage: placeholderImage)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            // 然后使用传入的 placeholder
            else if let placeholder = placeholder {
                placeholder
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Color.gray.opacity(0.3)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    // 正在加载视图
    private var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.white)
            
            if loadProgress > 0 {
                Text("\(Int(loadProgress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.top, 8)
            }
        }
    }
    // 下载失败视图
    private var errorView: some View {
        VStack(spacing: 12) {
            if let errorPlaceholder = errorPlaceholder {
                errorPlaceholder
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Text("图片加载失败")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.7))
            
            Button("重试") {
                loadImage()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.2))
            .foregroundStyle(.white)
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 手势
extension DDZoomableImageView {
    
    // 单击手势
    private var singleTapGesture: some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                onSingleTap()
            }
    }
    
    // 双击手势
    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                onDoubleTap()
            }
    }
    
    // 捏合手势
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                
                let newScale = scale * delta
                scale = max(newScale, minScale)
                
                onDragChange()
            }
            .onEnded { _ in
                withAnimation(.spring()) {
                    if scale > maxScale {
                        scale = maxScale
                    }
                    lastScale = minScale
                    if scale <= minScale {
                        resetToIdentity()
                    }
                }
                
            }
    }
    // 拖拽手势
    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard scale > minScale else { return }
                
                // 1. 计算图片实际显示尺寸
                let containerAspect = geometry.size.width / geometry.size.height
                let imageAspect = imageOriginalSize.width / imageOriginalSize.height
                
                var scaledImageWidth: CGFloat
                var scaledImageHeight: CGFloat
                
                if containerAspect > imageAspect {
                    // 容器更宽，图片高度撑满
                    scaledImageHeight = geometry.size.height * scale
                    scaledImageWidth = scaledImageHeight * imageAspect
                } else {
                    // 容器更高，图片宽度撑满
                    scaledImageWidth = geometry.size.width * scale
                    scaledImageHeight = scaledImageWidth / imageAspect
                }
                
                // 3. 计算新的偏移量
                // 注意：value.translation 是手指在屏幕上的移动距离
                // 需要转换为图片的偏移量，所以要除以缩放比例
                let newOffsetX = lastOffset.width + value.translation.width / scale
                let newOffsetY = lastOffset.height + value.translation.height / scale
                
                // 4. 限制偏移量在允许范围内
                offset.width = newOffsetX
                offset.height = newOffsetY
                
                onDragChange()
            }
            .onEnded { value in
                // 只有放大的时候才去处理下边的问题
                guard scale > minScale else { return }
                // 判断图片边界问题
                snapToNearestEdge()
                onDragEnd()
            }
    }
}

// MARK: - 吸边方法
extension DDZoomableImageView {
    // 处理边界问题 也就是让图片吸边
    private func snapToNearestEdge() {
        guard scale > minScale else { return }
        
        // 计算图片显示的实际尺寸（保持宽高比）
        let containerAspect = geometry.size.width / geometry.size.height
        let imageAspect = imageOriginalSize.width / imageOriginalSize.height
        
        var scaledImageWidth: CGFloat
        var scaledImageHeight: CGFloat
        
        if containerAspect > imageAspect {
            // 容器更宽，图片高度撑满
            scaledImageHeight = geometry.size.height * scale
            scaledImageWidth = scaledImageHeight * imageAspect
        } else {
            // 容器更高，图片宽度撑满
            scaledImageWidth = geometry.size.width * scale
            scaledImageHeight = scaledImageWidth / imageAspect
        }
        
        // 计算图片在屏幕中的实际边界
        let scaledOffsetWidth = offset.width * scale
        let scaledOffsetHeight = offset.height * scale
        
        let leftEdge = geometry.size.width / 2 - scaledImageWidth / 2 + scaledOffsetWidth
        let rightEdge = geometry.size.width / 2 + scaledImageWidth / 2 + scaledOffsetWidth
        let topEdge = geometry.size.height / 2 - scaledImageHeight / 2 + scaledOffsetHeight
        let bottomEdge = geometry.size.height / 2 + scaledImageHeight / 2 + scaledOffsetHeight
        
        var newOffset = offset
        
        // 水平方向吸边（只有图片宽度大于屏幕宽度时才需要）
        if scaledImageWidth > geometry.size.width {
            if leftEdge > 0 {
                // 左边有空白，吸到左边：图片左边与屏幕左边对齐
                newOffset.width = (scaledImageWidth / 2 - geometry.size.width / 2) / scale
            } else if rightEdge < geometry.size.width {
                // 右边有空白，吸到右边：图片右边与屏幕右边对齐
                newOffset.width = (geometry.size.width / 2 - scaledImageWidth / 2) / scale
            }
        } else {
            // 图片宽度小于等于屏幕宽度时，水平方向居中对齐
            newOffset.width = 0
        }
        let fixedDistance = ignoreSafeArea ? CGFloat(14) / scale : 0
        // 垂直方向吸边（只有图片高度大于屏幕高度时才需要）
        if scaledImageHeight > geometry.size.height {
            if topEdge > 0 {
                // 上边有空白，吸到上边：图片顶部与屏幕顶部对齐
                // 公式解释：要使 topEdge = 0，即 geometry.size.height/2 - scaledImageHeight/2 + offset*scale = 0
                // 解方程：offset = (scaledImageHeight/2 - geometry.size.height/2) / scale
                newOffset.height = (scaledImageHeight / 2 - geometry.size.height / 2) / scale - fixedDistance
            } else if bottomEdge < geometry.size.height {
                // 下边有空白，吸到下边：图片底部与屏幕底部对齐
                // 公式解释：要使 bottomEdge = geometry.size.height
                newOffset.height = (geometry.size.height / 2 - scaledImageHeight / 2) / scale - fixedDistance
            }
        } else {
            // 图片高度小于等于屏幕高度时，垂直方向居中对齐
            newOffset.height = 0
        }
        
        // 使用动画更新
        withAnimation(.spring(duration: 0.3)) {
            offset = newOffset
            lastOffset = offset
        }
    }
}
// MARK: - 其他私有方法
extension DDZoomableImageView {
    // MARK: - 状态重置
    private func resetToIdentity() {
        withAnimation(.spring()) {
            scale = minScale
            offset = .zero
            lastOffset = .zero
        }
    }
    /// 加载图片
    private func loadImage() {
        // 如果有预估尺寸，直接使用
        if let estimatedSize = source.estimatedSize, estimatedSize != .zero {
            imageOriginalSize = estimatedSize
        }
        
        switch source {
        case .remote(let imageUrl, _, _):
            loadRemoteImage(imageUrl)
        case .local(let localSource):
            loadLocalImage(localSource)
        }
    }
    /// 加载远程图片
    private func loadRemoteImage(_ imageUrl: String) {
        guard let url = URL(string: imageUrl) else {
            loadFailed = true
            return
        }
        isLoading = true
        loadFailed = false
        loadProgress = 0
        KingfisherManager.shared.retrieveImage(with: url) { result in
            DispatchQueue.main.async {
                isLoading = false
                loadProgress = 1.0
                switch result {
                case .success(let value):
                    imageOriginalSize = value.image.size
                case .failure(let error):
                    print("图片加载失败", error)
                    loadFailed = true
                }
            }
        }
    }
    
    /// 加载本地图片
    private func loadLocalImage(_ localSource: DDImageSource.LocalImageSource) {
        if let image = localSource.image {
            // UIImage
            imageOriginalSize = image.size
        } else if let url = localSource.fileURL {
            // 本地文件（支持 GIF）
            imageOriginalSize = getImageSizeFromLocalFile(url)
        } else if let assetName = localSource.assetName {
            // Asset
            if let image = UIImage(named: assetName) {
                imageOriginalSize = image.size
            } else {
                // 可能是系统图标
                if let image = UIImage(systemName: assetName) {
                    imageOriginalSize = image.size
                }
            }
        }
    }
    
    /// 从本地文件获取图片尺寸
    private func getImageSizeFromLocalFile(_ url: URL) -> CGSize {
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: url.path) else {
            return .zero
        }
        
        // 对于 GIF，使用 ImageIO 获取尺寸（不加载完整图片）
        if url.pathExtension.lowercased() == "gif",
           let data = try? Data(contentsOf: url),
           let source = CGImageSourceCreateWithData(data as CFData, nil),
           let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any] {
            
            if let width = properties[kCGImagePropertyPixelWidth] as? CGFloat,
               let height = properties[kCGImagePropertyPixelHeight] as? CGFloat {
                return CGSize(width: width, height: height)
            }
        }
        
        // 对于普通图片，使用 UIImage
        if let image = UIImage(contentsOfFile: url.path) {
            return image.size
        }
        
        return .zero
    }
}
