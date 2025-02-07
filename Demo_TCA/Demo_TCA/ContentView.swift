//
//  ContentView.swift
//  Demo_TCA
//
//  Created by Yin Bob on 2025/2/7.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        NavigationView {
            List {
                NavigationLink(destination: CounterView()) {
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

struct CounterView: View {
    @State var count: Int = 0
    
    var body: some View {
        //self.$count // Binding<Int>
        
        VStack{
            HStack{
                Button(action: { self.count -= 1 }) {
                    Text("-")
                }
                Text("\(self.count)")
                Button(action: { self.count += 1}) {
                    Text("+")
                }
            }
            Button(action: {}) {
                Text("Is this prime?")
            }
            Button(action: {}) {
                Text("What is the \(ordinal(self.count))th prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter demo")
    }
}

#Preview {
    ContentView()
    //CounterView()
}
