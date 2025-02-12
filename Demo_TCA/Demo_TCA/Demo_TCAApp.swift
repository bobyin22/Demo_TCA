//
//  Demo_TCAApp.swift
//  Demo_TCA
//
//  Created by Yin Bob on 2025/2/7.
//

import SwiftUI
import ComposableArchitecture

@main
struct Demo_TCAApp: App {
    // 添加靜態 store 屬性
        static let store = Store(
            initialState: CounterFeature.State(),
            reducer: { CounterFeature()._printChanges() }
        )
        
        var body: some Scene {
            WindowGroup {
                ContentView(store: Demo_TCAApp.store)
            }
        }
}

/*
 AppState 是 ObservableObject
 應該由 @StateObject 在 Demo_TCAApp 內部管理，這樣它才能在 整個 app 生命周期中保持一致，不會因為 ContentView 重新建立而丟失數據。
 
 
 🚀 結論
 1.錯誤的地方：
    •Demo_TCAApp.swift 沒有傳入 state，導致 ContentView 初始化失敗。
 2.正確做法：
    •在 Demo_TCAApp 內部 建立 @StateObject var state = AppState()，然後 傳入 ContentView(state: state)。

 */
