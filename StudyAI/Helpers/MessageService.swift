import Foundation
import FirebaseAuth
import FirebaseFirestore
import MessageKit
import FirebaseFunctions

let MessageService = _MessageService()

final class _MessageService {

    // TODO: Complete chat functionality implementation.
    // This service should handle sending messages to the OpenAI API
    // via the "getMessages" Cloud Function and managing chat history.

    func callOpenAIAPI(data: [String: Any], completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let funcGetData = Functions.functions().httpsCallable("getMessages")
        funcGetData.timeoutInterval = 300000

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
