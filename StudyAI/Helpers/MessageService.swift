//
//  MessageService.swift
//  StudyAI
//
//  Created by Anthony Fasano on 7/17/23.
//

//
//  UserServices.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/16/23.
//


import Foundation
import FirebaseAuth
import FirebaseFirestore
import MessageKit
import FirebaseFunctions

let MessageService = _MessageService()


var messages = [MessageType]()

var data:[String:Any] = [:]

final class _MessageService {
    
    func callOpenAIAPI(data: [String:Any]) {
        let funcGetData = Functions.functions().httpsCallable("getMessages")
        funcGetData.timeoutInterval = 300000

        
        //let data1 : [String: Any] = [
            //"message" : str, "model":gptType, "max_tokens":maxTokens, "system":system]
    }
    
    
    
    
}

