//
//  ImagePreviewDemoApp.swift
//  ImagePreviewDemo
//
//  Created by Meet on 2026/5/14.
//

import SwiftUI
import DDImagePreview
@main
struct ImagePreviewDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                // 方案一 这里全局注册预览界面
                .ddWithGlobalPreview()
        }
    }
}
