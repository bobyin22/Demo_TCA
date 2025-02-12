//
//  ContentView.swift
//  Demo_TCA
//
//  Created by Yin Bob on 2025/2/7.
//

import SwiftUI
import Combine
import ComposableArchitecture

// MARK: - 核心概念
/// TCA 主要有四個重要的積木：
/// 1. State (狀態) - 就像是遊戲的記分板，記錄所有數據
/// 2. Action (動作) - 就像遊戲的按鈕，定義可以做什麼事
/// 3. Reducer (處理器) - 就像是遊戲規則，定義按下按鈕後要做什麼
/// 4. Store (商店) - 就像是遊戲主機，把以上三個東西組合在一起
struct CounterFeature: Reducer {
    
    // MARK: - State (狀態)
    /// 這裡定義了我們需要記住的所有東西
    struct State: Equatable {
        var count = 0
        var favoritePrimes: [Int] = []
        var isPrimeModalShown = false
        var alertNthPrime: PrimeAlert?  // 顯示第N個質數的提示框
    }
    
    // MARK: - Action (動作)
    /// 這裡定義了所有可以執行的動作，就像遊戲手把上的按鈕
    enum Action: Equatable {
        case incrementButtonTapped
        case decrementButtonTapped
        case isPrimeButtonTapped
        case primeModalDismissed
        case saveFavoritePrimeTapped
        case removeFavoritePrimeTapped
        case removeFavoritePrimes(IndexSet)
        case nthPrimeButtonTapped
        case nthPrimeResponse(TaskResult<Int>)
        case alertDismissed
    }
    
    // MARK: 依賴
    /// 使用 @Dependency 注入 wolfram 客戶端
    /// 這樣做的好處是：
    /// 1. 容易測試：可以替換成測試用的假 API
    /// 2. 解耦合：Feature 不需要知道 WolframClient 具體如何實現
    /// 3. 靈活性：可以輕易切換不同的實現（比如切換到不同的 API 服務）
    @Dependency(\.wolfram) var wolfram
    
    // MARK: - Reducer (處理器)
    /// 這裡定義了每個動作該如何改變狀態，就像遊戲規則說明書
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .incrementButtonTapped:
                state.count += 1
                return .none
                
            case .decrementButtonTapped:
                state.count -= 1
                return .none
                
            case .isPrimeButtonTapped:
                state.isPrimeModalShown = true
                return .none
                
            case .primeModalDismissed:
                state.isPrimeModalShown = false
                return .none
                
            case .saveFavoritePrimeTapped:
                state.favoritePrimes.append(state.count)
                return .none
                
            case .removeFavoritePrimeTapped:
                state.favoritePrimes.removeAll(where: { $0 == state.count })
                return .none
                
            case let .removeFavoritePrimes(indexSet):
                state.favoritePrimes.remove(atOffsets: indexSet)
                return .none
                
            case .nthPrimeButtonTapped:
                return .run { [count = state.count] send in
                    await send(.nthPrimeResponse(
                        TaskResult { try await wolfram.nthPrime(count) }
                    ))
                }
                
            case let .nthPrimeResponse(.success(prime)):
                state.alertNthPrime = PrimeAlert(prime: prime)
                return .none
                
            case .nthPrimeResponse(.failure):
                // 可以在這裡處理錯誤
                return .none
                
            case .alertDismissed:
                state.alertNthPrime = nil
                return .none
            }
        }
    }
}

struct PrimeAlert: Identifiable, Equatable {
    let prime: Int
    
    var id: Int { self.prime }
}

// MARK: - 輔助函數
private func isPrime (_ p: Int) -> Bool {
    if p <= 1 { return false }
    if p <= 3 { return true }
    for i in 2...Int(sqrtf(Float(p))) {
        if p % i == 0 { return false }
    }
    return true
}

// 改變文字顯示，當數字變化，有質數或沒有質數
private func ordinal(_ n: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .ordinal
    return formatter.string(for: n) ?? ""
}

// MARK: - API Response Models
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

// MARK: - Dependencies（依賴）
/// @Dependency 是 TCA 提供的一個特殊屬性包裝器（Property Wrapper）
/// 用來管理外部依賴，比如 API 呼叫、資料庫存取等

// MARK: - 定義依賴
struct WolframClient {
    var nthPrime: (Int) async throws -> Int // 定義一個可以獲取第 n 個質數的函數類型
}

// MARK: - 註冊依賴
extension WolframClient: DependencyKey { // 讓 WolframClient 成為一個依賴鍵
    private static let wolframAlphaApiKey = "123"  // 你的 API Key
    
    static let liveValue = Self(
        nthPrime: { number in
            let components = URLComponents(string: "https://api.wolframalpha.com/v2/query")!
            var queryItems = [
                URLQueryItem(name: "input", value: "prime number \(number)"),
                URLQueryItem(name: "format", value: "plaintext"),
                URLQueryItem(name: "output", value: "JSON"),
                URLQueryItem(name: "appid", value: wolframAlphaApiKey)
            ]
            
            var urlComponents = components
            urlComponents.queryItems = queryItems
            
            guard let url = urlComponents.url else {
                throw APIError.noResult
            }
            
            print("Request URL: \(url.absoluteString)") // 添加調試信息

            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 打印 API 響應
            if let responseString = String(data: data, encoding: .utf8) {
                print("API Response: \(responseString)")
            }
            
            let result = try JSONDecoder().decode(WolframAlphaResult.self, from: data)
            
            guard let prime = result.queryresult.pods
                .first(where: { $0.primary == .some(true) })?
                .subpods
                .first?
                .plaintext,
                  let number = Int(prime)
            else {
                throw APIError.noResult
            }
            
            return number
        }
    )
}

enum APIError: Error {
    case noResult
}

extension DependencyValues { // 將 WolframClient 註冊到依賴系統中
    var wolfram: WolframClient {
        get { self[WolframClient.self] }
        set { self[WolframClient.self] = newValue }
    }
}



// MARK: - Views
struct ContentView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationView {
                List {
                    NavigationLink("Counter Demo") {
                        CounterView(store: store)
                    }
                    NavigationLink("Favorite Primes") {
                        FavoritePrimesView(store: store)
                    }
                }
                .navigationTitle("State Management")
            }
        }
    }
}

struct CounterView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                HStack {
                    Button("-") {
                        viewStore.send(.decrementButtonTapped)
                    }
                    Text("\(viewStore.count)")
                    Button("+") {
                        viewStore.send(.incrementButtonTapped)
                    }
                }
                Button("Is this prime?") {
                    viewStore.send(.isPrimeButtonTapped)
                }
                Button("What is the \(ordinal(viewStore.count))th prime?") {
                    viewStore.send(.nthPrimeButtonTapped)
                }
            }
            .font(.title)
            .navigationTitle("Counter Demo")
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isPrimeModalShown,
                    send: .primeModalDismissed
                )
            ) {
                IsPrimeModalView(store: store)
            }
            .alert(
                item: viewStore.binding(
                    get: \.alertNthPrime,
                    send: .alertDismissed
                )
            ) { alert in
                Alert(
                    title: Text("The \(ordinal(viewStore.count)) prime is \(alert.prime)"),
                    dismissButton: .default(Text("Ok"))
                )
            }
        }
    }
}

// MARK: - 收藏質數視圖
struct FavoritePrimesView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            List {
                ForEach(viewStore.favoritePrimes, id: \.self) { prime in
                    Text("\(prime)")
                }
                .onDelete { indexSet in
                    viewStore.send(.removeFavoritePrimes(indexSet))
                }
            }
            .navigationTitle("Favorite Primes")
        }
    }
}

// MARK: - 質數檢查模態視圖
struct IsPrimeModalView: View {
    let store: StoreOf<CounterFeature>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                if isPrime(viewStore.count) {
                    Text("\(viewStore.count) is prime 🎉")
                    if viewStore.favoritePrimes.contains(viewStore.count) {
                        Button("Remove from favorite primes") {
                            viewStore.send(.removeFavoritePrimeTapped)
                        }
                    } else {
                        Button("Save to favorite primes") {
                            viewStore.send(.saveFavoritePrimeTapped)
                        }
                    }
                } else {
                    Text("\(viewStore.count) is not prime 😢")
                }
            }
        }
    }
}

#Preview {
    ContentView(store: Demo_TCAApp.store)
}

