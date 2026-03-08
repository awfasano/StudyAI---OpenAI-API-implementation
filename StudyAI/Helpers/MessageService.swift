import Foundation
import FirebaseAuth
import FirebaseFirestore
import MessageKit
import FirebaseFunctions

let MessageService = _MessageService()

final class _MessageService {

    func sendMessage(messages: [[String: String]], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let funcGetData = Functions.functions().httpsCallable("getMessages")
        funcGetData.timeoutInterval = 300

        let data: [String: Any] = [
            "messages": messages,
            "max_tokens": 2000,
            "model": "gpt-4",
        ]

        funcGetData.call(data) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let dict = result?.data as? [String: Any] {
                completion(.success(dict))
            }
        }
    }
}
