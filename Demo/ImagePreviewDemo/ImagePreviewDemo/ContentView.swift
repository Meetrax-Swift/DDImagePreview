//
//  ContentView.swift
//  ImagePreviewDemo
//
//  Created by Meet on 2026/5/14.
//

import SwiftUI
import DDImagePreview
import Kingfisher
struct ContentView: View {
    @State private var showPopup = false
    @State private var previewIndex: Int = 0
    
    
    private let cartoonList = [
        "https://p6.itc.cn/images01/20201212/016bf17ea7124f5397e1b32f46c07a46.gif",
        "https://ww4.sinaimg.cn/mw690/0079ZTGxly1hoektd1julj30v91vokjl.jpg",
        "https://img0.baidu.com/it/u=4020805637,1948310268&fm=253&app=138&f=JPEG?w=681&h=1216",
        "https://wx3.sinaimg.cn/mw690/005xQRaSgy1i76bv93kr4j30u01hpjxt.jpg",
        
    ]
    private var cartoonSource: [DDImageSource] {
        let newArray = cartoonList.map { item in
            return DDImageSource.url(item)
        }
        return newArray
    }
    // 定义九宫格4列
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    /// 底部九宫格
    private let sources: [DDImageSource] = [
        .url("https://b0.bdstatic.com/ugc/_xMj9RKxrBLh97irv2_UtA93c67323778295b148de493ff44f7e17.jpg"),
        .url("https://wx3.sinaimg.cn/large/719d2175ly1hky0j73nz7j21hc0u0aeo.jpg"),
        .url("https://pic.rmb.bdstatic.com/bjh/250325/beautify/d09d80ef2952714b3f1ec5ef2d88f4c3.jpeg?for=bg"),
        .url("https://p6.itc.cn/images01/20201212/016bf17ea7124f5397e1b32f46c07a46.gif"),
        .url("https://pic.rmb.bdstatic.com/bjh/bc146662b3f/250920/f15fad6ce5176f53acf332e63aac904b.jpeg?for=bg"),
        .url("https://iknow-pic.cdn.bcebos.com/71cf3bc79f3df8dc3ebb7b0fdf11728b461028ae"),
        .localName("test"),
        .localFile(Bundle.main.url(forResource: "test1", withExtension: "gif")!)
    ]

    private let imageWidth: CGFloat = 80
    var body: some View {
        VStack {
            Text("你好")
            LazyVGrid(columns: columns) {
                ForEach(cartoonList.prefix(9).indices, id: \.self) { index in
                    let image = cartoonList[index]
                    if image.hasSuffix(".gif") {
                        KFAnimatedImage(URL(string: image))
                            .placeholder {
                                DDImagePreViewConstants.placehoderImage
                            }
                            .scaledToFill()
                            .frame(width: imageWidth, height: imageWidth)
                            .clipped()
                            .onTapGesture {
                                // 方案二
                                showPopup = true
                                previewIndex = index
                            }
                    } else {
                        KFImage(URL(string: image))
                            .placeholder {
                                DDImagePreViewConstants.placehoderImage
                            }
                            .resizable()
                            .scaledToFill()
                            .frame(width: imageWidth, height: imageWidth)
                            .clipped()
                            .onTapGesture {
                                // 方案二
                                showPopup = true
                                previewIndex = index
                            }
                    }
                }
            }
            
            Spacer()
            
            HStack {
                // 自定义九宫格视图
                DDGridImageView(sources: sources, columns: 4, spacing: 0) { current in
                    //方案一： 通过API调用预览界面
                    DDImagePreviewManager.show(sources: sources,
                                               initialIndex: current,
                                               config: DDImagePreviewConfig(ignoreSafeArea: false,
                                                                            isCanSave: true))
                }
            }.padding(.horizontal, 50)
            
        }
        // 方案二 可以添加自定视图
        .ddImagePreview(isPresented: $showPopup,
                        sources: cartoonSource,
                        initialIndex: previewIndex) { current in
            // 这里就是添加的自定义视图
            VStack {
                Spacer()
                Text("我是一个自定义视图， 你可以写任何东西\(current)")
                    .foregroundColor(current % 2 == 0 ? .purple : .red)
                Button {
                    print(current)
                } label: {
                    Text("click me")
                        .foregroundColor(current % 2 == 0 ? .purple : .red)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.5))
                .foregroundColor(.white)
                .cornerRadius(8)
                Spacer()
                    .frame(height: 100)
            }
        }
    }
}

#Preview {
    ContentView()
}

