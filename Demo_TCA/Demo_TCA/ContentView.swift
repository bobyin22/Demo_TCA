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

struct CounterView: View {
    @State var count: Int = 0
    
    var body: some View {
        VStack{
            HStack{
                Button(action: {}) {
                    Text("-")
                }
                Text("\(self.count)")
                Button(action: {}) {
                    Text("+")
                }
            }
            Button(action: {}) {
                Text("Is this prime?")
            }
            Button(action: {}) {
                Text("What is the 0th prime?")
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
