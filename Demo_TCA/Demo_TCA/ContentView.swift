//
//  ContentView.swift
//  Demo_TCA
//
//  Created by Yin Bob on 2025/2/7.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var state: AppState // 從 CounterView 提取出來

    var body: some View {
        
        NavigationView {
            List {
                NavigationLink(destination: CounterView(state: self.state)) {
                    Text("Counter demo")
                }
                NavigationLink(destination: EmptyView()) {
                    Text("Favorite primes ")
                }
            }
            .navigationTitle("State management")
        }
        
    }
}

// 改變文字顯示，當數字變化，有質數或沒有質數
private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

//BindableObject
class AppState: ObservableObject {   // ❌舊教學是 BindableObject ✅新教學是 ObservableObject
    @Published var count = 0
    
//    var count = 0 {                // ❌舊教學 還需要自己寫 didSet ✅新教學是 @Published
//        didSet {
//            self.didChange.send()
//        }
//    }
    
    //var didChange: AppState.PublisherType ❌舊教學
    //var didChange: PassthroughSubject<Void, Never> ❌舊教學
}

struct CounterView: View {
    //@ObjectBinding var count: Int  // ❌舊教學是 @ObjectBinding ✅新教學是 @ObservedObject
    @ObservedObject var state: AppState
    
    var body: some View {
        //self.$count // Binding<Int>
        
        VStack{
            HStack{
                Button(action: { self.state.count -= 1 }) {
                    Text("-")
                }
                Text("\(self.state.count)")
                Button(action: { self.state.count += 1}) {
                    Text("+")
                }
            }
            Button(action: {}) {
                Text("Is this prime?")
            }
            Button(action: {}) {
                Text("What is the \(ordinal(self.state.count))th prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter demo")
    }
}

#Preview {
    ContentView(state: AppState())
}
