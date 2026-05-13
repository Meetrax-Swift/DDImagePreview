//
//  DDImagePreviewManager.swift
//  DDImagePreviewDemo
//
//  Created by Meet on 2025/12/12.
//

import SwiftUI
import Combine

@MainActor
public final class DDImagePreviewManager: ObservableObject {

    public static let shared = DDImagePreviewManager()

    /// 是否显示
    @Published public var isPresented: Bool = false

    /// 数据源
    @Published public var sources: [DDImageSource] = []

    /// 起始索引
    @Published public var initialIndex: Int = 0

    /// 预览配置
    @Published public var config: DDImagePreviewConfig = .default

    // MARK: - 私有属性

    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupBindings()
    }

    /// 查看预览图
    public static func show(
        sources: [DDImageSource],
        initialIndex: Int = 0,
        config: DDImagePreviewConfig = .default
    ) {
        guard !sources.isEmpty else { return }

        shared.sources = sources
        shared.initialIndex = min(initialIndex, max(0, sources.count - 1))
        shared.config = config
        shared.isPresented = true
    }

    /// 显示单张图片预览
    public static func show(
        source: DDImageSource,
        config: DDImagePreviewConfig = .default
    ) {
        show(sources: [source], config: config)
    }

    /// 隐藏预览
    public static func hide() {
        shared.isPresented = false
    }

    /// 单张图片预览
    public static func show(_ source: DDImageSource) {
        show(source: source)
    }

    /// 多张图片预览
    public static func show(_ sources: [DDImageSource]) {
        show(sources: sources)
    }

    /// 多张图片预览
    public static func show(_ sources: [DDImageSource], at index: Int) {
        show(sources: sources, initialIndex: index)
    }
}

extension DDImagePreviewManager {

    private func setupBindings() {
        $isPresented
            .sink { [weak self] isPresented in
                guard let self else { return }

                if !isPresented {
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(250))

                        self.sources = []
                        self.initialIndex = 0
                        self.config = .default
                    }
                }
            }
            .store(in: &cancellables)
    }
}
