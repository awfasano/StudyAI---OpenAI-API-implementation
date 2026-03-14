import Foundation
import FirebaseFirestore
import FirebaseFirestore
import PDFKit

let DocumentService = _DocumentService()

protocol reloadDelegate {
    func reload(success: Bool)
}

protocol alertDelegate {
    func showAlertDel(success: Bool)
}

final class _DocumentService {
    let db = Firestore.firestore()

    var updated = false
    var fields: [String: [String: [docInfo]]] = [
        "Math": ["Algebra": [], "Geometry": [], "Trigonometry": [], "Calculus": [], "Statistics and Probability": []],
        "Science": ["Biology": [], "Chemistry": [], "Physics": [], "Earth Science": [], "Environmental Science": []],
        "Social Sciences": ["Macroeconomics": [], "Microeconomics": [], "Psychology": [], "Government": [], "Geography": []],
        "History": ["US History": [], "European History": [], "World History": [], "Art History": []],
        "English": ["Poetry": [], "Essays": [], "Grammar": []],
        "Foreign Languages": ["Spanish": [], "French": [], "Japanese": [], "Chinese": [], "German": [], "Korean": []]
    ]

    var keysFields = ["Math", "Science", "Social Sciences", "History", "English", "Foreign Languages"]
    var delegate: reloadDelegate?
    var listener: ListenerRegistration?

    func movedTobackground() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        listener?.remove()
        UserService.userListener?.remove()
    }

    func getData() {
        if updated { return }

        let indicator = Indicator()
        indicator.showIndicator()

        listener = db.collection("users").document(UserService.user.id).collection("Past Questions").addSnapshotListener { snapshot, error in

            self.fields = [
                "Math": ["Algebra": [], "Geometry": [], "Trigonometry": [], "Calculus": [], "Statistics and Probability": []],
                "Science": ["Biology": [], "Chemistry": [], "Physics": [], "Earth Science": [], "Environmental Science": []],
                "Social Sciences": ["Macroeconomics": [], "Microeconomics": [], "Psychology": [], "Government": [], "Geography": []],
                "History": ["US History": [], "European History": [], "World History": [], "Art History": []],
                "English": ["Poetry": [], "Essays": [], "Grammar": []],
                "Foreign Languages": ["Spanish": [], "French": [], "Japanese": [], "Chinese": [], "German": [], "Korean": []]
            ]

            self.keysFields = ["Math", "Science", "Social Sciences", "History", "English", "Foreign Languages"]

            if let _ = error {
                self.delegate?.reload(success: false)
            } else {
                snapshot?.documents.forEach({ doc in
                    if let dict = doc.data() as? [String: [String: Any]] {
                        dict.keys.forEach { key in
                            guard let entryData = dict[key] else { return }
                            let tempDocInfo = docInfo(data: entryData, key: key, subjecID: doc.documentID)
                            self.fields[doc.documentID]?[tempDocInfo.field]?.append(tempDocInfo)
                        }
                    }
                })
                indicator.hideIndicator {
                    self.delegate?.reload(success: true)
                }
                self.updated = true
            }
        }
    }

    func deleteDocument(subject: String, docInformation: docInfo) {
        let ref = db.collection("users").document(UserService.user.id).collection("Past Questions").document(docInformation.field)
        let group = DispatchGroup()
        group.enter()
        let indicator = Indicator()
        indicator.showIndicator()
        indicator.label.text = ""
        ref.updateData([docInformation.id: FieldValue.delete()]) { error in
            if let _ = error {
                group.leave()
            } else {
                group.leave()
            }
        }
        group.notify(queue: .main) {
            indicator.hideIndicator(completion: nil)
        }
    }

    func putDocument(subject: String, field: String, text: String, question: String?, docType: String, questionType: String, questionTopic: String, indicator: Indicator) {
        let ref = db.collection("users").document(UserService.user.id).collection("Past Questions").document(subject)
        let date = Date().getFormattedDate(format: "yyyy-MM-dd HH:mm a")

        let dict = [DocumentService.randomString(length: 10): ["question": (question ?? ""), "text": text, "docType": docType, "date": date, "field": field, "questionType": questionType, "questionTopic": questionTopic]]

        var success = false
        let group = DispatchGroup()
        group.enter()

        ref.setData(dict, merge: true) { error in
            success = error == nil
            group.leave()
        }
        group.notify(queue: .main) {
            self.delegate?.reload(success: success)
            self.updated = false
            indicator.hideIndicator(completion: nil)
        }
    }

    func deletePastQuestion(doc: docInfo) {
        let ref = db.collection("users").document(UserService.user.id).collection("Past Questions").document(doc.subject)
        let indicator = Indicator()
        indicator.showIndicator()
        ref.updateData([doc.id: FieldValue.delete()]) { error in
            if let _ = error {
                self.delegate?.reload(success: false)
                indicator.hideIndicator(completion: nil)
            } else {
                self.delegate?.reload(success: true)
                guard let index = self.fields[doc.subject]?[doc.field]?.firstIndex(where: { $0.id == doc.id }) else {
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
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
