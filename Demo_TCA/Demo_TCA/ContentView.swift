//
//  ContentView.swift
//  Demo_TCA
//
//  Created by Yin Bob on 2025/2/7.
//

import SwiftUI
import Combine

struct ContentView: View {
    @ObservedObject var state: AppState

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

class AppState: ObservableObject {
    @Published var count = 0
}

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPrimeModalShown: Bool = false

    var body: some View {
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
            Button(action: {
                self.isPrimeModalShown = true
            }) {
                Text("Is this prime?")
            }
            Button(action: {}) {
                Text("What is the \(ordinal(self.state.count))th prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter demo")
        
        // ✅新寫法
        .sheet(isPresented: $isPrimeModalShown) {
            IsPrimeModalView(state: state)
        }
        
        // ❌舊寫法
//        .presentation(
//            self.isPrimeModalShown
//            ? Modal(
//                IsPrimeModalView(state: self.state),
//                onDismiss: { self.isPrimeModalShown = false }
//                )
//            : nil)
    }
}

private func isPrime (_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrt(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}

struct IsPrimeModalView: View {
    //@ObjectBinding var state: AppState // ❌舊寫法
    @ObservedObject var state: AppState

    
    var body: some View {
        VStack {
            if isPrime(self.state.count) {
                Text("\(self.state.count) is prime 🎉")
            } else {
                Text("\(self.state.count) is prime 😥")
            }
            Text("I don't know if \(self.state.count) is prime")
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("Save/remove to/from favorite primes")
            })
        }
    }
}

#Preview {
    ContentView(state: AppState())
}
