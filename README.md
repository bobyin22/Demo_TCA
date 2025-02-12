# Demo_TCA

兩種寫法的主要差異：

### 1. 狀態管理的方式不同：

```swift
// 舊寫法：使用 ObservableObject
class AppState: ObservableObject {
    @Published var count = 0
    @Published var favoritePrimes: [Int] = []
}

// TCA寫法：使用 State 結構體
struct CounterFeature.State {
    var count = 0
    var favoritePrimes: [Int] = []
    var isPrimeModalShown = false
    var alertNthPrime: PrimeAlert?
}
```
就像是：
舊寫法：把所有東西放在一個大箱子裡（AppState）  
TCA：把東西分類放在不同的小箱子裡（每個功能都有自己的 State）

---
### 2. 動作處理的方式不同：

```swift
// 舊寫法：直接在按鈕中修改狀態
Button(action: { self.state.count += 1 })

// TCA寫法：透過 Action 來修改
Button("+") {
    viewStore.send(.incrementButtonTapped)
}
```
就像是：  
舊寫法：直接動手改東西  
TCA：寫紙條（Action）告訴管理員（Reducer）要改什麼  

---
### 3. API 調用的方式不同：
```swift
// 舊寫法：使用回調（Callback）
func nthPrime(_ n: Int, callback: @escaping (Int?) -> Void)

// TCA寫法：使用 async/await
var nthPrime: (Int) async throws -> Int
```
就像是：  
舊寫法：問問題後要等別人打電話回來告訴你答案  
TCA：直接等在那裡到有答案為止  

---
### 4. 視圖的組織方式不同：
```swift
// 舊寫法：直接傳遞 AppState
struct CounterView: View {
    @ObservedObject var state: AppState
}

// TCA寫法：使用 Store
struct CounterView: View {
    let store: StoreOf<CounterFeature>
}
```
就像是：  
舊寫法：每個視圖都可以直接碰觸所有狀態  
TCA：每個視圖只能看到自己需要的部分  

---
### 5. 錯誤處理的方式：
```swift
 // 舊寫法：使用可選值（Optional）
callback(Int?)

// TCA寫法：使用 TaskResult
case let .nthPrimeResponse(.success(prime))
case .nthPrimeResponse(.failure)
```
就像是：  
舊寫法：如果失敗就給空值  
TCA：明確告訴你成功或失敗的原因  

就像是：  
舊寫法像是在小房間裡隨意擺放東西  
TCA 像是把東西整理得井井有條的大房子  

---
