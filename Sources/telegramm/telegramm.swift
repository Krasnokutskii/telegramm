import TelegramBotSDK
import OpenAISwift
import Foundation
@available(macOS 10.15.0, *)
@main
public struct telegramm {
    //    let token = readToken(from: "BOT_TOKEN")
    //    static let bot = TelegramBot(token: token)
    //    static let router = Router(bot: bot)
    //let router = Router(bot: TelegramBot(token: readToken(from: "BOT_TOKEN")))
    public static func main() {
        let token = readToken(from: "BOT_TOKEN")
        let bot = TelegramBot(token: token)
        let router = Router(bot: bot)
        let openAI = OpenAISwift(authToken: readToken(from: "TOKEN"))
        
        router["grammar"] = { context in
            guard let greeting = context.message?.from else { return false }
            context.respondAsync("Ну ты и какашка конечно \(greeting.firstName)")
            return true
        }
        router[.text] = { context in
            guard let text = context.message?.text else { return false }
            openAI.sendCompletion(with: text,model: .gpt3(.ada) ,maxTokens: 20 ){ result in
                switch result {
                case .success(let success):
                    let response = success.choices.first?.text ?? "no text"
                    context.respondSync(response)
                case .failure:
                    print("failure") 
                }
            }
            return true
        }
        
        while let update = router.bot.nextUpdateSync(){
            print(update)
            do {
                try router.process(update: update)
            }catch {
                print("Error: \(error)")
            }
            
        }
    }
}
