import SwiftUI

struct ContentView: View {
    @State private var zipcode = ""
    @State private var address1 = "" // 都道府県
    @State private var address2 = "" // 市区町村
    @State private var address3 = "" // 町域
    var fullAddress: String {
        return "\(address1) \(address2) \(address3)"
    }
    
    var body: some View {
        VStack {
            Text("郵便番号から住所を検索")
                .font(.title)
                .padding()
            
            TextField("郵便番号を入力", text: $zipcode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)
            
            Button(action: {
                searchAddress()
            }) {
                Text("検索")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        
            Text("住所: \(fullAddress)")
                .padding()
        }
    }
    
    private func searchAddress() {
        guard let url = URL(string: "http://zipcloud.ibsnet.co.jp/api/search?zipcode=\(zipcode)") else {
            print("URLが無効です")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("APIエラー: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ZipcodeResponse.self, from: data)
                if let firstResult = result.results.first {
                    self.address1 = firstResult.address1
                    self.address2 = firstResult.address2
                    self.address3 = firstResult.address3
                } else {
                    self.address1 = "住所が見つかりません"
                    self.address2 = ""
                    self.address3 = ""
                }
            } catch {
                print("デコードエラー: \(error.localizedDescription)")
            }
        }.resume()
    }
}

#Preview {
    ContentView()
}

struct ZipcodeResponse: Decodable {
    struct Result: Decodable {
        let address1: String
        let address2: String
        let address3: String
    }
    
    let results: [Result]
}

