import Foundation

struct User {
    var id: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var isVerified: Bool = false
    var isVerifiable: Bool = false
    var receivedTokens: Bool = false
    var tokensRemaining: Int = 0

    init(id: String = "", firstName: String = "", lastName: String = "", email: String = "", stripeId: String = "", isVerified: Bool = false, receivedTokens: Bool = false) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.isVerified = isVerified
        self.receivedTokens = receivedTokens
    }

    init(data: [String: Any]) {
        id = data["uid"] as? String ?? ""
        email = data["email"] as? String ?? ""
        firstName = data["firstName"] as? String ?? ""
        lastName = data["lastName"] as? String ?? ""
        isVerified = data["isVerified"] as? Bool ?? false
        isVerifiable = data["isVerifiable"] as? Bool ?? false
        receivedTokens = data["receivedTokens"] as? Bool ?? true
        tokensRemaining = data["tokensRemaining"] as? Int ?? 0
    }

    static func modelToData(user: User) -> [String: Any] {
        return [
            "id": user.id,
            "email": user.email,
            "firstName": user.firstName,
            "lastName": user.lastName,
            "isVerified": user.isVerified,
            "receivedTokens": user.receivedTokens
        ]
    }
}

struct docInfo {
    var id: String
    var text: String
    var question: String
    var docType: String
    var dateString: String
    var date: Date
    var field: String
    var subject: String
    var questionType: String
    var questionTopic: String

    init(data: [String: Any], key: String, subjecID: String) {
        self.id = key
        self.text = data["text"] as? String ?? ""
        self.question = data["question"] as? String ?? ""
        self.docType = data["docType"] as? String ?? "txt"
        self.dateString = data["date"] as? String ?? ""
        self.field = data["field"] as? String ?? ""
        self.subject = subjecID
        self.questionType = data["questionType"] as? String ?? ""
        self.questionTopic = data["questionTopic"] as? String ?? ""

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm a"
        self.date = formatter.date(from: self.dateString) ?? Date()
    }
}
