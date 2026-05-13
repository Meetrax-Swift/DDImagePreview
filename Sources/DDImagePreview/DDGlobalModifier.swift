//
//  DDGlobalModifier.swift
//  DDImagePreview
//
//  Created by Meet on 2025/12/10.
//

import SwiftUI

/// 这个是全局显示的弹窗 展示的内容自己写
public struct DDFullScreenPopupModifier<PopupContent: View, Background: View>: ViewModifier {
    
    /// 是否显示弹窗
    @Binding var isPresented: Bool
    /// 动画类型
    let animation: Animation
    /// 背景
    let background: () -> Background
    /// 弹出的内筒
    let popContent: () -> PopupContent
    /// 点击空白处是否消失
    let dismissOnTapOutside: Bool
    
    // 新增：用于控制视图是否存在的状态
    @State private var isContentPresented = false
    // 新增：用于控制透明度的状态
    @State private var opacity: Double = 0
    
    public func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            ZStack {
                // 当前试图
                content
                
                // 弹出的试图
                if isContentPresented {
                    ZStack {
                        // 弹出背景颜色
                        background()
                            .opacity(opacity) // 使用独立的透明度控制
                            .ignoresSafeArea()
                            .onTapGesture {
                                if dismissOnTapOutside {
                                    isPresented = false
                                }
                            }
                        // 弹出的视图
                        popContent()
                            .opacity(opacity) // 使用独立的透明度控制
                    }
                }
            }
            .onChange(of: isPresented) { oldvalue, newValue in
                if newValue {
                    showPopup()
                } else {
                    dismissPopup()
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    /// 显示弹窗
    private func showPopup() {
        isContentPresented = true
        withAnimation(animation) {
            opacity = 1
        }
    }
    /// 弹窗消失
    private func dismissPopup() {
        if #available(iOS 17.0, *) {
            withAnimation(animation) {
                opacity = 0
            } completion: {
                isContentPresented = false
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

/// 图片预览修饰器
public struct DDImagePreviewModifier<CustomView: View>: ViewModifier {
    // MARK: - 属性
    @Binding var isPresented: Bool
    let sources: [DDImageSource]
    let initialIndex: Int
    let config: DDImagePreviewConfig
    let custom: ((_ current: Int) -> CustomView)?
    // MARK: - 初始化
    /// 初始化器（带有自定义指示器）
    public init(
        isPresented: Binding<Bool>,
        sources: [DDImageSource],
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default,
        @ViewBuilder custom: @escaping (_ current: Int) -> CustomView
    ) {
        self._isPresented = isPresented
        self.sources = sources
        self.initialIndex = initialIndex
        self.config = config
        self.custom = custom
    }
    
    /// 初始化器（没有自定义指示器）
    public init(
        isPresented: Binding<Bool>,
        sources: [DDImageSource],
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default
    ) where CustomView == AnyView {
        self._isPresented = isPresented
        self.sources = sources
        self.initialIndex = initialIndex
        self.config = config
        self.custom = nil
    }
    
    // MARK: - 主体
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                if let custom = custom {
                    DDImagePreview(
                        isPresented: $isPresented,
                        sources: sources,
                        initialIndex: initialIndex,
                        config: config,
                        custom: custom
                    )
                    .transition(.opacity)
                    .zIndex(9999)
                    .modifier(DDConditionalIgnoreSafeArea(ignore: config.ignoreSafeArea))
                } else {
                    DDImagePreview(
                        isPresented: $isPresented,
                        sources: sources,
                        initialIndex: initialIndex,
                        config: config
                    )
                    .transition(.opacity)
                    .zIndex(9999)
                    .modifier(DDConditionalIgnoreSafeArea(ignore: config.ignoreSafeArea))
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

/// 全局注册 需要吧这个注册到全局的组件或者布局上
public struct DDGlobalImagePreviewModifier: ViewModifier {
    @StateObject private var manager = DDImagePreviewManager.shared
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            if manager.isPresented {
                DDImagePreview(
                    isPresented: $manager.isPresented,
                    sources: manager.sources,
                    initialIndex: manager.initialIndex,
                    config: manager.config
                )
                .transition(.opacity)
                .zIndex(9999)
                .modifier(DDConditionalIgnoreSafeArea(ignore: manager.config.ignoreSafeArea))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: manager.isPresented)
    }
}

struct DDConditionalIgnoreSafeArea: ViewModifier {
    let ignore: Bool
    func body(content: Content) -> some View {
        if ignore {
            content.ignoresSafeArea()
        } else {
            content
        }
    }
}


extension View {
    
    // MARK: - 基本用法
    
    /// 带有自定义视图的多图片预览
    /// - Parameters:
    ///   - sources: 数据源
    ///   - isPresented: 是否显示
    ///   - initialIndex: 开始的索引
    ///   - config: 显示配置
    ///   - custom: 自定义视图
    /// - Returns: 预览图
   public func ddImagePreview<CustomView: View>(
        isPresented: Binding<Bool>,
        sources: [DDImageSource],
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default,
        @ViewBuilder custom: @escaping (_ current: Int) -> CustomView
    ) -> some View {
        modifier(DDImagePreviewModifier(
            isPresented: isPresented,
            sources: sources,
            initialIndex: initialIndex,
            config: config,
            custom: custom
        ))
    }
    
    /// 不带有自定义视图的多图片预览
    /// - Parameters:
    ///   - sources: 数据源
    ///   - isPresented: 是否显示
    ///   - initialIndex: 开始的索引
    ///   - config: 显示配置
    /// - Returns: 预览图
    public func ddImagePreview(
        isPresented: Binding<Bool>,
        sources: [DDImageSource],
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default
    ) -> some View {
        modifier(DDImagePreviewModifier(
            isPresented: isPresented,
            sources: sources,
            initialIndex: initialIndex,
            config: config
        ))
    }
    
    /// 带自定义视图的单图预览
    /// - Parameters:
    ///   - source: 数据源
    ///   - isPresented: 是否显示
    ///   - config: 开始的索引
    ///   - custom: 自定视图
    /// - Returns: 预览图
    public func ddImagePreview<CustomView: View>(
        isPresented: Binding<Bool>,
        source: DDImageSource,
        config: DDImagePreviewConfig = .default,
        @ViewBuilder custom: @escaping (_ current: Int) -> CustomView
    ) -> some View {
        ddImagePreview(
            isPresented: isPresented,
            sources: [source],
            config: config,
            custom: custom
        )
    }
    
    /// 不带自定义视图的单图预览
    /// - Parameters:
    ///   - source: 数据源
    ///   - isPresented: 是否显示
    ///   - config: 开始的索引
    /// - Returns: 预览图
    public func ddImagePreview(
        isPresented: Binding<Bool>,
        source: DDImageSource,
        config: DDImagePreviewConfig = .default
    ) -> some View {
        ddImagePreview(
            isPresented: isPresented,
            sources: [source],
            config: config
        )
    }
    
    // MARK: - 快捷方法
    /// 带自定义视图的单图预览
    /// - Parameters:
    ///   - source: 数据源
    ///   - isPresented: 是否显示
    ///   - config: 开始的索引
    ///   - custom: 自定视图
    /// - Returns: 预览图
    public func ddPreview<CustomView: View>(
        _ source: DDImageSource,
        isPresented: Binding<Bool>,
        config: DDImagePreviewConfig = .default,
        @ViewBuilder custom: @escaping (_ current: Int) -> CustomView
    ) -> some View {
        ddImagePreview(
            isPresented: isPresented,
            source: source,
            config: config,
            custom: custom
        )
    }
    
    /// 不带自定义视图的单图预览
    /// - Parameters:
    ///   - source: 数据源
    ///   - isPresented: 是否显示
    ///   - config: 开始的索引
    /// - Returns: 预览图
    public func ddPreview<CustomView: View>(
        _ source: DDImageSource,
        isPresented: Binding<Bool>,
        config: DDImagePreviewConfig = .default
    ) -> some View {
        ddImagePreview(
            isPresented: isPresented,
            source: source,
            config: config
        )
    }
    
    /// 带有自定义视图的多图片预览
    /// - Parameters:
    ///   - sources: 数据源
    ///   - isPresented: 是否显示
    ///   - initialIndex: 开始的索引
    ///   - config: 显示配置
    ///   - custom: 自定义视图
    /// - Returns: 预览图
    public func ddMultiPreview<CustomView: View>(
        _ sources: [DDImageSource],
        isPresented: Binding<Bool>,
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default,
        @ViewBuilder custom: @escaping (_ current: Int) -> CustomView
    ) -> some View {
        ddImagePreview(
            isPresented: isPresented,
            sources: sources,
            initialIndex: initialIndex,
            config: config,
            custom: custom
        )
    }
    
    /// 不带有自定义视图的多图片预览
    /// - Parameters:
    ///   - sources: 数据源
    ///   - isPresented: 是否显示
    ///   - initialIndex: 开始的索引
    ///   - config: 显示配置
    /// - Returns: 预览图
    public func ddMultiPreview(
        _ sources: [DDImageSource],
        isPresented: Binding<Bool>,
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default
    ) -> some View {
        ddImagePreview(
            isPresented: isPresented,
            sources: sources,
            initialIndex: initialIndex,
            config: config
        )
    }
    
    // MARK: - 全局支持
    
    /// 添加全局图片预览支持
    public func ddWithGlobalPreview() -> some View {
        modifier(DDGlobalImagePreviewModifier())
    }
}


extension View {
    
    /// 全屏显示样式
    /// - Parameters:
    ///   - isPresent: 是否显示
    ///   - dismissOnTapOutside: 点击空白处是否消失
    ///   - animation: 弹出动画
    ///   - background: 背景
    ///   - content: 弹出内容
    /// - Returns: 被修饰的样式
    public func ddFullScreenPopup<PopupContent: View, Background: View>(
        isPresent: Binding<Bool>,
        dismissOnTapOutside: Bool = true,
        animation: Animation = .easeOut(duration: 0.25),
        @ViewBuilder background: @escaping () -> Background = {Color.white},
        @ViewBuilder content: @escaping () -> PopupContent
    ) -> some View {
        self.modifier(
            DDFullScreenPopupModifier(
                isPresented: isPresent,
                animation: animation,
                background: background,
                popContent: content,
                dismissOnTapOutside: dismissOnTapOutside
            )
        )
    }
}
