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
                NavigationLink(destination: FavoritePrimeView(state: self.state)) {
                    Text("Favorite primes")
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
    @Published var favoritePrimes: [Int] = []
}

struct PrimeAlert: Identifiable {
  let prime: Int

  var id: Int { self.prime }
}

struct CounterView: View {
    @ObservedObject var state: AppState
    @State var isPrimeModalShown: Bool = false
    //@State var alertNthPrime: Int?
    @State var alertNthPrime: PrimeAlert?
    
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
            Button(action: {
                nthPrime(self.state.count) { prime in
                    if let prime = prime {
                        self.alertNthPrime = PrimeAlert(prime: prime)
                    }
                }
            }) {
                Text("What is the \(ordinal(self.state.count))th prime?")
            }
        }
        .font(.title)
        .navigationTitle("Counter demo")

        // ✅新寫法
        .sheet(isPresented: $isPrimeModalShown) {
            IsPrimeModalView(state: state)
        }
//                ❌舊寫法
//                .presentation(
//                    self.isPrimeModalShown
//                    ? Modal(
//                        IsPrimeModalView(state: self.state),
//                        onDismiss: { self.isPrimeModalShown = false }
//                        )
//                    : nil)
        
        
        .alert(item: self.$alertNthPrime) { alert in
          Alert(
            title: Text("The \(ordinal(self.state.count)) prime is \(alert.prime)"),
            dismissButton: .default(Text("Ok"))
          )
        }
//        ❌舊寫法
//        .presentation(self.$alertNthPrime) { n in
//            Alert(title: Text("The \(ordinal(self.state.count)) prime is \(n)"),
//                  dismissButton: .destructive(Text("Ok"))
//            )
//        }
    }
}

private func isPrime (_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
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
                if self.state.favoritePrimes.contains(self.state.count) {
                    Button(action: { self.state.favoritePrimes.removeAll(where: { $0 == self.state.count })}, label: {
                        Text("Remove from favorite primes")
                    })
                } else {
                    Button(action: { self.state.favoritePrimes.append(self.state.count) }, label: {
                        Text("Save to from favorite primes")
                    })
                }
            } else {
                Text("\(self.state.count) is not prime 😥")
            }
        }
    }
}

// MARK: API
struct WolframAlphaResult: Decodable {
  let queryresult: QueryResult

  struct QueryResult: Decodable {
    let pods: [Pod]

    struct Pod: Decodable {
      let primary: Bool?
      let subpods: [SubPod]

      struct SubPod: Decodable {
        let plaintext: String
      }
    }
  }
}


func wolframAlpha(query: String, callback: @escaping (WolframAlphaResult?) -> Void) -> Void {
  var components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
  components.queryItems = [
    URLQueryItem(name: "input", value: query),
    URLQueryItem(name: "format", value: "plaintext"),
    URLQueryItem(name: "output", value: "JSON"),
    URLQueryItem(name: "appid", value: wolframAlphaApiKey), //這裡換上自己註冊的Api key
  ]

    //wolframAlphaApiKey
    //"JPLW25-XU846GVWT8"

  URLSession.shared.dataTask(with: components.url(relativeTo: nil)!) { data, response, error in
    callback(
      data
        .flatMap { try? JSONDecoder().decode(WolframAlphaResult.self, from: $0) }
    )
  }
  .resume()
}

func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void) -> Void {
  wolframAlpha(query: "prime \(n)") { result in
    callback(
      result
        .flatMap {
          $0.queryresult
            .pods
            .first(where: { $0.primary == .some(true) })?
            .subpods
            .first?
            .plaintext
      }
      .flatMap(Int.init)
    )
  }
}

// MARK: 存儲質數的View
struct FavoritePrimeView: View {
    @ObservedObject var state: AppState
    
    var body: some View {
        List {
            ForEach(self.state.favoritePrimes, id: \.self) { prime in
                Text("\(prime)")
            }
            .onDelete { indexSet in
                for index in indexSet {
                    self.state.favoritePrimes.remove(at: index)
                }
            }
        }
        .navigationTitle("Favorite Primes")
    }
}


#Preview {
    ContentView(state: AppState())
}
