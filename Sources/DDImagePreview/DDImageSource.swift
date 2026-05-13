//
//  DDImageSource.swift
//  DDImagePreviewDemo
//
//  Created by Meet on 2025/12/15.
//
import UIKit

/// 图片数据源
public enum DDImageSource: Equatable {
    /// 远程图片
    case remote(String, placeholder: UIImage? = nil, size: CGSize? = nil)
    /// 本地图片
    case local(LocalImageSource)
    
    /// 本地图片源
    public struct LocalImageSource: Equatable {
        /// UIImage 实例
        public let image: UIImage?
        /// 本地文件 URL（用于 GIF 或大文件）
        public let fileURL: URL?
        /// Asset 名称
        public let assetName: String?
        /// 占位图
        public let placeholder: UIImage?
        /// 图片实际尺寸 如果有可传可不传 没有一定不要传
        public let size: CGSize?
        
        public init(
            image: UIImage? = nil,
            fileURL: URL? = nil,
            assetName: String? = nil,
            placeholder: UIImage? = nil,
            size: CGSize? = nil
        ) {
            self.image = image
            self.fileURL = fileURL
            self.assetName = assetName
            self.placeholder = placeholder
            self.size = size
        }
        
        public static func == (lhs: LocalImageSource, rhs: LocalImageSource) -> Bool {
            // 通过文件 URL 或 Asset 名称比较
            return lhs.fileURL == rhs.fileURL && lhs.assetName == rhs.assetName
        }
    }
    
    // MARK: - 便捷初始化器（使用不同的方法名避免冲突）
    
    
    /// 创建远程图片源
    /// - Parameter url: 远程图片地址
    /// - Returns: 图片源
    public static func url(_ url: String) -> DDImageSource {
        return .remote(url, placeholder: nil, size: nil)
    }
    
    
    /// 创建带占位图的远程图片源
    /// - Parameters:
    ///   - url: 远程图片地址
    ///   - placeholderImage: 占位图
    /// - Returns: 图片源
    public static func url(_ url: String, placeholderImage: UIImage?) -> DDImageSource {
        return .remote(url, placeholder: placeholderImage, size: nil)
    }
    
    
    /// 创建带预估尺寸的远程图片源
    /// - Parameters:
    ///   - url: 远程图片地址
    ///   - estimatedSize: 图片实际尺寸 如果有可传可不传 没有一定不要传
    /// - Returns: 图片源
    public static func url(_ url: String, size: CGSize) -> DDImageSource {
        return .remote(url, placeholder: nil, size: size)
    }
    
    
    /// 创建完整的远程图片源
    /// - Parameters:
    ///   - url: 远程图片地址
    ///   - placeholderImage: 占位图
    ///   - estimatedSize: 图片实际尺寸 如果有可传可不传 没有一定不要传
    /// - Returns: 图片源
    public static func url(_ url: String, placeholderImage: UIImage?, size: CGSize) -> DDImageSource {
        return .remote(url, placeholder: placeholderImage, size: size)
    }
    
    
    /// 从 UIImage 创建本地图片源
    /// - Parameters:
    ///   - image: UIImage
    ///   - placeholderImage: 占位图
    /// - Returns: 图片源
    public static func image(_ image: UIImage, placeholderImage: UIImage? = nil) -> DDImageSource {
        return .local(LocalImageSource(
            image: image,
            placeholder: placeholderImage,
            size: image.size
        ))
    }
    
    
    /// 从本地文件 URL 创建图片源（支持 GIF）
    /// - Parameters:
    ///   - url: 本地的图片路径
    ///   - placeholderImage: 占位图
    /// - Returns: 图片源
    public static func localFile(_ url: URL, placeholderImage: UIImage? = nil) -> DDImageSource {
        return .local(LocalImageSource(
            fileURL: url,
            placeholder: placeholderImage
        ))
    }
    
    
    /// 从 Asset 名称创建图片源
    /// - Parameters:
    ///   - name:  Asset 名字
    ///   - placeholderImage: 占位图
    /// - Returns: 图片源
    public static func asset(_ name: String, placeholderImage: UIImage? = nil) -> DDImageSource {
        return .local(LocalImageSource(
            assetName: name,
            placeholder: placeholderImage
        ))
    }
    
    
    /// 从图片名创建图片源（自动判断 Bundle 或 Asset）
    /// - Parameters:
    ///   - name: 图片名字
    ///   - placeholderImage: 占位图
    /// - Returns: 图片源
    public static func localName(_ name: String, placeholderImage: UIImage? = nil) -> DDImageSource {
        if let image = UIImage(named: name) {
            return .image(image, placeholderImage: placeholderImage)
        } else {
            return .asset(name, placeholderImage: placeholderImage)
        }
    }
    
    // MARK: - 计算属性
    
    /// 是否为 GIF 图片
    public var isGIF: Bool {
        switch self {
        case .remote(let url, _, _):
            return url.lowercased().hasSuffix(".gif")
        case .local(let localSource):
            if let url = localSource.fileURL {
                return url.pathExtension.lowercased() == "gif"
            }
            return false
        }
    }
    
    /// 获取占位图
    public var placeholderImage: UIImage? {
        switch self {
        case .remote(_, let placeholder, _):
            return placeholder
        case .local(let localSource):
            return localSource.placeholder
        }
    }
    
    /// 获取预估尺寸
    public var estimatedSize: CGSize? {
        switch self {
        case .remote(_, _, let size):
            return size
        case .local(let localSource):
            return localSource.size ?? localSource.image?.size
        }
    }
    
    /// 获取文件 URL（如果是本地文件）
    public var fileURL: URL? {
        if case .local(let localSource) = self {
            return localSource.fileURL
        }
        return nil
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: DDImageSource, rhs: DDImageSource) -> Bool {
        switch (lhs, rhs) {
        case let (.remote(url1, placeholder1, size1), .remote(url2, placeholder2, size2)):
            return url1 == url2 && placeholder1 == placeholder2 && size1 == size2
        case let (.local(source1), .local(source2)):
            return source1 == source2
        default:
            return false
        }
    }
}
