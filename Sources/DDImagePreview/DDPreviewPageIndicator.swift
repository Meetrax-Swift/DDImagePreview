//
//  DDPreviewPageIndicator.swift
//  DDImagePreview
//
//  Created by Meet on 2025/12/11.
//

import SwiftUI

/// 页码指示器
public struct DDPreviewPageIndicator: View {
    
    // MARK: - 属性
    let currentIndex: Int
    let totalCount: Int
    let color: Color
    let normalIndicatorColor: Color
    let backgroundColor: Color
    let style: DDPageIndicatorConfig.IndicatorStyle
    // MARK: - 初始化
    public init(
        currentIndex: Int,
        totalCount: Int,
        color: Color,
        normalIndicatorColor:  Color = Color.white,
        backgroundColor: Color = Color.black.opacity(0.4),
        style: DDPageIndicatorConfig.IndicatorStyle = .dot
    ) {
        self.currentIndex = currentIndex
        self.totalCount = totalCount
        self.color = color
        self.normalIndicatorColor = normalIndicatorColor
        self.backgroundColor = backgroundColor
        self.style = style
    }
    
    // MARK: - 主体
    public var body: some View {
        let spacing: CGFloat = style == .dot ? 6 : 1
        HStack(spacing: spacing) {
            if style == .dot {
                ForEach(0..<totalCount, id: \.self) { index in
                    Capsule()
                        .fill(index == currentIndex ? color : normalIndicatorColor)
                        .frame(width: index == currentIndex ? 20 : 8, height: 8)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentIndex)
                }
            } else {
                Text("\(currentIndex + 1)")
                    .foregroundStyle(color)
                    .font(.system(size: 17, weight: .medium))
                Text("/")
                    .foregroundStyle(color)
                    .font(.system(size: 16, weight: .medium))
                Text("\(totalCount)")
                    .foregroundStyle(color)
                    .font(.system(size: 17, weight: .medium))
            }
            
        }
        .padding(.horizontal, 12)
        .background(
            Capsule()
                .fill(backgroundColor)
        )
        .allowsHitTesting(false)
    }
}
