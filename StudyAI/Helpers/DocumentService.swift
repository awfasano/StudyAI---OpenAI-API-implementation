//
//  DocumentService.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/28/23.
//
//
//  UserService.swift
//  Waited
//
//  Created by Anthony Fasano on 12/14/20.
//

import Foundation
import Firebase
import FirebaseFirestore
import PDFKit

let DocumentService = _DocumentService()

protocol reloadDelegate{
    func reload(success:Bool)
}

protocol alertDelegate{
    func showAlertDel(success:Bool)
}

final class _DocumentService {
    let db = Firestore.firestore()
    
    var updated = false
    var fields:[String:[String:[docInfo]]] = ["Math":["Algebra":[], "Geometry":[], "Trigonometry":[],"Calculus":[],"Statistics and Probability":[]],
                  "Science":["Biology":[], "Chemistry":[], "Physics":[], "Earth Science":[], "Environmental Science":[]],
                  "Social Sciences":["Macroeconomics":[], "Microeconomics":[], "Pyschology":[], "Government":[], "Geography":[]],
                  "History":["US History":[], "European History":[],"World History":[], "Art History":[]],
                  "English":["Poetry":[], "Essays":[], "Grammar":[]],
                  "Foriegn Languages":["Spanish":[],"French":[],"Japanese":[],"Chinese":[],"German":[],"Korean":[]]
    ]
    
    var keysFields = ["Math","Science","Social Sciences","History","English", "Foriegn Languages"]
    var delegate: reloadDelegate?
    var listener:ListenerRegistration?
    
    func movedTobackground(){
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc func appMovedToBackground() {
            listener?.remove()
            UserService.userListener?.remove()
        }
    
    func getData(){
        if updated{
            return
        }
        
        var success = false
        let indicator = Indicator()
        indicator.showIndicator()
        
        listener = db.collection("users").document(UserService.user.id).collection("Past Questions").addSnapshotListener{ snapshot, error in
            
            self.fields = ["Math":["Algebra":[], "Geometry":[], "Trigonometry":[],"Calculus":[],"Statistics and Probability":[]],
                          "Science":["Biology":[], "Chemistry":[], "Physics":[], "Earth Science":[], "Environmental Science":[]],
                          "Social Sciences":["Macroeconomics":[], "Microeconomics":[], "Pyschology":[], "Government":[], "Geography":[]],
                          "History":["US History":[], "European History":[],"World History":[], "Art History":[]],
                          "English":["Poetry":[], "Essays":[], "Grammar":[]],
                          "Foriegn Languages":["Spanish":[],"French":[],"Japanese":[],"Chinese":[],"German":[],"Korean":[]]
            ]
            
            self.keysFields = ["Math","Science","Social Sciences","History","English", "Foriegn Languages"]
            
            if let error = error {
                self.delegate?.reload(success: false)
            }
            else {
                print(snapshot?.count)
                snapshot?.documents.forEach({ doc in
                        if let dict = doc.data() as? [String:[String:Any]]{
                            dict.keys.forEach { key in
                                print("key")
                                print(key)
                                print("doc id")
                                print(doc.documentID)
                                print("dictionary")
                                print(dict[key])
                                let tempDocInfo = docInfo.init(data:dict[key]!,key:key, subjecID:doc.documentID)
                                print(tempDocInfo)
                                self.fields[doc.documentID]?[tempDocInfo.field]?.append(tempDocInfo)
                            }
                        }
                    //print(self.fields)
                })
                indicator.hideIndicator {
                    self.delegate?.reload(success: true)
                }
                self.updated = true
            }
        }
    }
    
    func deleteDocument(subject:String, docInformation:docInfo) {
        let ref = db.collection("users").document(UserService.user.id).collection("Past Questions").document(docInformation.field)
        var success = false
        let group = DispatchGroup()
        group.enter()
        let indicator = Indicator()
        indicator.showIndicator()
        indicator.label.text = ""
        ref.updateData([docInformation.id : FieldValue.delete()]) { error in
            if let error = error {
                success = false
                group.leave()
            }
            else {
                success = true
                group.enter()
            }
        }
        group.notify(queue: .main){
            //self.delegate?.reload(success: success)
            //self.updated = false
            indicator.hideIndicator(completion: nil)
        }
    }
    
    func putDocument(subject:String, field:String, text:String, question:String?, docType:String, questionType:String, questionTopic:String, indicator: Indicator){

        let ref = db.collection("users").document(UserService.user.id).collection("Past Questions").document(subject)
        let date = Date().getFormattedDate(format:  "yyyy-MM-dd HH:mm a")
        
        let dict = [DocumentService.randomString(length: 10):["question":(question ?? ""),"text":text,"docType":docType, "date":date,"field":field,"questionType":questionType,"questionTopic":questionTopic]]

        var success = false
        let group = DispatchGroup()
        group.enter()
        //indicator.label.text = ""
        
        ref.setData(dict, merge: true) { error in
            if let error = error {
                success = false
                group.leave()
            }
            else {
                success = true
                group.leave()
            }
        }
        group.notify(queue: .main){
            self.delegate?.reload(success: success)
            self.updated = false
            indicator.hideIndicator(completion: nil)
        }
        // Upload data and metadata
        //htmlRef.putData(data, metadata: metadata)
        // Upload file and metadata
        //mountainsRef.putFile(from: localFile, metadata: metadata)
    }
    
    func deletePastQuestion(doc:docInfo){
        let ref = db.collection("users").document(UserService.user.id).collection("Past Questions").document(doc.subject)
        let indicator = Indicator()
        indicator.showIndicator()
        ref.updateData([doc.id:FieldValue.delete()]) { error in
            if let error = error {
                self.delegate?.reload(success: false)
                indicator.hideIndicator(completion: nil)
            }
            else {
                self.delegate?.reload(success: true)
                
                guard let index = self.fields[doc.subject]?[doc.field]?.firstIndex(where: { docInfo in
                    docInfo.id == doc.id
                })else {
                    return
                }
                self.fields[doc.subject]?[doc.field]?.remove(at: index)
                indicator.hideIndicator(completion: nil)
            }
        }
    }
    
    func formatNumber(_ n: Int) -> String {
        let num = abs(Double(n))
        let sign = (n < 0) ? "-" : ""

        switch num {
        case 1_000_000_000...:
            var formatted = num / 1_000_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)B"

        case 1_000_000...:
            var formatted = num / 1_000_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)M"

        case 1_000...:
            var formatted = num / 1_000
            formatted = formatted.reduceScale(to: 1)
            return "\(sign)\(formatted)K"

        case 0...:
            return "\(n)"

        default:
            return "\(sign)\(n)"
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
        }
    }



    
    


