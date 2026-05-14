//
//  DDImagePreviewConfig.swift
//  DDImagePreview
//
//  Created by Meet on 2025/12/10.
//

import SwiftUI


@MainActor
public struct DDPageIndicatorConfig {
    // MARK: - 指示器位置枚举
    public enum IndicatorPosition {
        case top
        case bottom
    }
    public enum IndicatorStyle {
        case dot
        case text
    }
    /// 是否显示页码指示器
    public var show: Bool = true
    /// 指示器位置（顶部/底部）
    public var position: IndicatorPosition = .bottom
    /// 指示器样式
    public var style: IndicatorStyle = .dot
    /// 指示器偏移数值 这是距离上边距或者下边距的距离 负值距离屏幕边框更近 正直距离屏幕边框更远
    public var offset: CGFloat = 0.0
    /// 指示器颜色（选中的颜色 当style是text的时候指的是文字的颜色）
    public var color: Color = .white
    /// more指示器颜色
    public var normalIndicatorColor: Color = Color.white.opacity(0.5)
    /// 指示器背景颜色
    public var backgroundColor: Color = .clear
    
    public static let `default` = DDPageIndicatorConfig()
    
    public init(
        show: Bool = true,
        position: IndicatorPosition = .bottom,
        style: IndicatorStyle = .text,
        offset: CGFloat = 0.0,
        color: Color = .white,
        normalIndicatorColor:  Color = Color.white.opacity(0.5),
        backgroundColor: Color = .clear
    ) {
        self.show = show
        self.position = position
        self.style = style
        self.offset = offset
        self.color = color
        self.normalIndicatorColor = normalIndicatorColor
        self.backgroundColor = backgroundColor
    }
    
}

public enum DDImagePreViewConstants {
    /// 背景颜色
    public static let backgroundColor = Color.black
    /// 最小缩放比例
    public static let minScale: CGFloat = 1.0
    /// 最大缩放比例
    public static let maxScale: CGFloat = 5
    /// 双击缩放比例
    public static let doubleTapScale: CGFloat = 2.0
    /// 占位图片
    public static let placehoderImage: Image = Image(systemName: "photo")
    /// 加载失败占位图
    public static let errorPlaceholderImage: Image = Image(systemName: "exclamationmark.triangle")
    /// 是否显示加载图片
    public static let showLoadingProgress: Bool = true
    /// 全屏状态下是否忽略安全区
    public static let ignoreSafeArea: Bool = true
}
@MainActor
public struct DDImagePreviewConfig {
    /// 全屏状态下是否忽略安全区
    public var ignoreSafeArea: Bool = DDImagePreViewConstants.ignoreSafeArea
    /// 背景颜色
    public var backgroundColor: Color = DDImagePreViewConstants.backgroundColor
    /// 是否可以保存图片到相册
    public var isCanSave: Bool = false
    /// 指示器配置
    public var indicator: DDPageIndicatorConfig = .default
    /// 最大缩放比例
    public var maxScale: CGFloat = DDImagePreViewConstants.maxScale
    /// 双击缩放比例
    public var doubleTapScale: CGFloat = DDImagePreViewConstants.doubleTapScale
    /// 最小缩放比例
    public var minScale: CGFloat = DDImagePreViewConstants.minScale
    /// 是否显示图片加载进度
    public var showLoadingProgress: Bool = DDImagePreViewConstants.showLoadingProgress
    /// 占位图
    public var placehoderImage: Image? = DDImagePreViewConstants.placehoderImage
    /// 加载失败占位图
    public var errorPlaceholderImage: Image? = DDImagePreViewConstants.errorPlaceholderImage
    /// 当图片缩放的时候是否隐藏自定的试图
    public var isShowCustomViewWhenZoom: Bool = false
    /// 默认配置
//    public static let `default` = DDImagePreviewConfig()
    
    
    /// 图片预览配置
    /// - Parameters:
    ///   - ignoreSafeArea: 是否忽略安全区
    ///   - backgroundColor: 预览区域背景颜色
    ///   - isCanSave: 是否可以保存图片到相册
    ///   - indicator: 指示器配置
    ///   - placeholderImage: 占位图片
    ///   - errorPlaceholderImage: 加载失败的错误占位图
    ///   - maxScale: 最大缩放比例
    ///   - doubleTapScale: 双击的时候缩放比例
    ///   - minScale: 最小缩放比例
    ///   - showLoadingProgress: 是否显示加载中只是器
    ///   - isShowCustomViewWhenZoom: 当放大的时候是否显示自定的View
    public init(
        ignoreSafeArea: Bool = DDImagePreViewConstants.ignoreSafeArea,
        backgroundColor: Color = DDImagePreViewConstants.backgroundColor,
        isCanSave: Bool = false,
        indicator: DDPageIndicatorConfig? = nil,
        placeholderImage: Image? = DDImagePreViewConstants.placehoderImage,
        errorPlaceholderImage: Image? = DDImagePreViewConstants.errorPlaceholderImage,
        maxScale: CGFloat = DDImagePreViewConstants.maxScale,
        doubleTapScale: CGFloat = DDImagePreViewConstants.doubleTapScale,
        minScale: CGFloat = DDImagePreViewConstants.minScale,
        showLoadingProgress: Bool = DDImagePreViewConstants.showLoadingProgress,
        isShowCustomViewWhenZoom: Bool = false
    ) {
        self.ignoreSafeArea = ignoreSafeArea
        self.backgroundColor = backgroundColor
        self.isCanSave = isCanSave
        self.indicator = indicator ?? DDPageIndicatorConfig()
        self.maxScale = maxScale
        self.doubleTapScale = doubleTapScale
        self.minScale = minScale
        self.placehoderImage = placeholderImage
        self.errorPlaceholderImage = errorPlaceholderImage
        self.isShowCustomViewWhenZoom = isShowCustomViewWhenZoom
    }
}
