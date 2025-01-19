//
//  objects.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/16/23.
//


import Foundation

struct User {
    var id: String
    var firstName: String
    var lastName: String
    var email: String
    var isVerified: Bool
    var receivedTokens: Bool
    
    init(id: String = "", firstName: String = "", lastName: String = "", email: String = "", stripeId: String = "",  isVerified:Bool = false, recievedTokens:Bool) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.isVerified = isVerified
    }
    
    init(data: [String:Any]) {
        id = data["uid"] as? String ?? ""
        email = data["email"] as? String ?? ""
        firstName = data["firstName"] as? String ?? ""
        lastName = data["lastName"] as? String ?? ""
        isVerified = data["isVerified"] as? Bool ?? false
        receivedTokens = data["receivedTokens"] as? Bool ?? true
    }
    
    static func modelToData(user : User) -> [String: Any] {

            let data : [String: Any] = [
                "id" : user.id,
                "email" : user.email,
                "firstName" : user.firstName,
                "lastName" : user.lastName,
                "isVerified" : user.isVerified,
                "receivedTokens" : user.receivedTokens
    ]
            return data
        }
    
}
