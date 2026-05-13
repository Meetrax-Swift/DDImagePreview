//
//  DDImageGridView.swift
//  DDImagePreviewDemo
//
//  Created by Meet on 2025/12/15.
//
import SwiftUI
import Kingfisher
public struct DDGridImageView: View {
    
    /// 数据源
    let sources: [DDImageSource]
    /// 列数
    var columns: Int = 3
    /// 图片间距
    var spacing: CGFloat = 0
    /// 点击图片回调
    let onTapSource: (_ current: Int) -> Void
    // 定义九宫格3列
    private var layout: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
    }
    // 获取屏幕宽度
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    public init(sources: [DDImageSource],
                columns: Int = 3,
                spacing: CGFloat = 0,
                onTapSource: @escaping (_ current: Int) -> Void) {
        self.sources = sources
        self.columns = columns
        self.spacing = spacing
        self.onTapSource = onTapSource
    }
    public var body: some View {
        GeometryReader { geometry in
            let containerWidth = geometry.size.width
            let itemWidth = max(0, (containerWidth - CGFloat(columns - 1) * spacing) / CGFloat(columns))
            
            LazyVGrid(columns: layout, spacing: spacing) {
                ForEach(sources.indices, id: \.self) { index in
                    gridItem(for: sources[index], itemWidth: itemWidth, index: index)
                }
            }
        }
        .frame(height: estimatedHeight)
    }
    
    private func gridItem(for source: DDImageSource, itemWidth: CGFloat, index: Int) -> some View {
        Group {
            if source.isGIF {
                gifView(for: source)
            } else {
                normalImageView(for: source)
            }
        }
        .frame(width: itemWidth, height: itemWidth)
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            onTapSource(index)
        }
    }
    
    // 估算高度（用于设置 .frame(height:)）
    private var estimatedHeight: CGFloat? {
        guard !sources.isEmpty else { return 0 }
        let rows = Int(ceil(Double(sources.count) / Double(columns)))
        let screenWidth = UIScreen.main.bounds.width
        let estimatedItemWidth = screenWidth / CGFloat(columns)
        return CGFloat(rows) * estimatedItemWidth + CGFloat(max(0, rows - 1)) * spacing
    }
    
    
    // MARK: - 子视图
    
    /// GIF 图片视图
    @ViewBuilder
    private func gifView(for source: DDImageSource) -> some View {
        Group {
            switch source {
            case .remote(let url, _, _):
                if let url = URL(string: url) {
                    KFAnimatedImage(url)
                        .placeholder {
                            placeholderView
                        }
                        .scaledToFill()
                } else {
                    placeholderView
                }
            case .local(let localSource):
                if let url = localSource.fileURL {
                    KFAnimatedImage(url)
                        .placeholder {
                            placeholderView
                        }
                        .scaledToFill()
                } else {
                    placeholderView
                }
            }
        }
    }
    
    /// 普通图片视图
    @ViewBuilder
    private func normalImageView(for source: DDImageSource) -> some View {
        Group {
            switch source {
            case .remote(let url, _, _):
                if let url = URL(string: url) {
                    KFImage(url)
                        .placeholder {
                            placeholderView
                        }
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholderView
                }
            case .local(let localSource):
                if let image = localSource.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else if let assetName = localSource.assetName {
                    Image(assetName)
                        .resizable()
                        .scaledToFill()
                } else {
                    placeholderView
                }
            }
        }
    }
    
    /// 占位图
    private var placeholderView: some View {
        DDImagePreViewConstants.placehoderImage
            .resizable()
            .scaledToFill()
            .foregroundColor(.gray.opacity(0.3))
    }
}
