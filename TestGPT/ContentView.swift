import SwiftUI
import OpenAISwift

struct Message: Hashable {
    let text: String
    let isUserMessage: Bool
}

struct ContentView: View {
    
    @State private var inputText = ""
    @State private var chatHistory: [Message] = []
    
    private var chatClient = OpenAISwift(authToken: "ここにAPIキーを記載")
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { scrollView in
                    ScrollView {
                        ForEach(chatHistory, id: \.self) { message in
                            HStack {
                                if message.isUserMessage {
                                    Spacer()
                                    Text(message.text)
                                        .padding(8)
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                } else {
                                    Text(message.text)
                                        .padding(8)
                                        .foregroundColor(.white)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                    Spacer()
                                }
                            }
                            .padding(4)
                            .id(message)
                        }
                    }
                    .onChange(of: chatHistory) { _ in
                        withAnimation {
                            scrollView.scrollTo(chatHistory.last, anchor: .bottom)
                        }
                    }
                }
                HStack {
                    TextField("Type your message here...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    Button(action: sendMessage) {
                        Text("Send")
                    }
                    .padding(.trailing)
                }
            }
            .navigationBarTitle("Chat with ChatGPT")
        }
    }
    
    func sendMessage() {
        if inputText.isEmpty { return }
        
        chatHistory.append(Message(text: inputText, isUserMessage: true))
        
        chatClient.sendCompletion(with: inputText, maxTokens: 500, completionHandler: { result in
            switch result {
            case .success(let model):
                DispatchQueue.main.async {
                    let output = model.choices.first?.text ?? ""
                    chatHistory.append(Message(text: output, isUserMessage: false))
                    self.inputText = ""
                }
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
