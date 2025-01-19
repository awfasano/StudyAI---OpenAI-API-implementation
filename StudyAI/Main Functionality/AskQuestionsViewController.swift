//
//  AskQuestionsViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 7/14/23.
//

import UIKit
import MessageKit

struct Sender:SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

struct Message:MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

//private var messages = [MessageType]()

class AskQuestionsViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate  {
    
    @IBOutlet weak var cancelButton: UIButton!
    
    let currentUser = Sender(photoURL: "", senderId: "self", displayName: "Anthony")
    
    let robot = Sender(photoURL: "", senderId: "other", displayName: "Carlisle")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: robot, messageId: "1", sentDate: Date().addingTimeInterval(-86400), kind: .text("Hi! I'm Carlisle. I'm here to assist you with any questions that you may.  Ask me about the content you just made or any other questions you may have.")))
        
        messages.append(Message(sender: robot, messageId: "2", sentDate: Date().addingTimeInterval(-76400), kind: .text("chill yourself please")))

        messages.append(Message(sender: currentUser, messageId: "3", sentDate: Date().addingTimeInterval(-66400), kind: .text("okay")))

        messages.append(Message(sender: robot, messageId: "4", sentDate: Date().addingTimeInterval(-56400), kind: .text("what can i help you with")))

        messages.append(Message(sender: currentUser, messageId: "5", sentDate: Date().addingTimeInterval(-6400), kind: .text("nothing, walk into traffic")))

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        // Do any additional setup after loading the view.
    }
    
    
    func currentSender() -> MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
    @IBAction func cancelOnTap(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
