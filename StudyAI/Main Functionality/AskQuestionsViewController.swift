//
//  AskQuestionsViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 7/14/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: MessageKit.SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKit.MessageKind
}

class AskQuestionsViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {

    @IBOutlet weak var cancelButton: UIButton!

    let currentUser = Sender(photoURL: "", senderId: "self", displayName: "You")
    let robot = Sender(photoURL: "", senderId: "other", displayName: "Carlisle")

    private var chatHistory: [[String: String]] = []
    private var isWaitingForResponse = false

    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self

        chatHistory.append([
            "role": "system",
            "content": "You are Carlisle, a helpful AI study assistant. " +
                "Help the user with their study questions. " +
                "Be concise and clear in your explanations.",
        ])

        let welcomeMessage = Message(
            sender: robot,
            messageId: "1",
            sentDate: Date(),
            kind: .text("Hi! I'm Carlisle. I'm here to assist you with any questions you may have. Ask me about your study material or anything else!")
        )
        messages.append(welcomeMessage)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
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

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !isWaitingForResponse else { return }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()

        let userMessage = Message(
            sender: currentUser,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(trimmedText)
        )
        messages.append(userMessage)
        messagesCollectionView.insertSections([messages.count - 1])
        messagesCollectionView.scrollToLastItem(animated: true)

        chatHistory.append(["role": "user", "content": trimmedText])

        isWaitingForResponse = true
        messageInputBar.sendButton.isEnabled = false

        MessageService.sendMessage(messages: chatHistory) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isWaitingForResponse = false
                self.messageInputBar.sendButton.isEnabled = true

                switch result {
                case .success(let dict):
                    if let info = dict["info"] as? [String: Any],
                       let content = info["content"] as? String {
                        self.chatHistory.append(["role": "assistant", "content": content])

                        let botMessage = Message(
                            sender: self.robot,
                            messageId: UUID().uuidString,
                            sentDate: Date(),
                            kind: .text(content)
                        )
                        self.messages.append(botMessage)
                        self.messagesCollectionView.insertSections([self.messages.count - 1])
                        self.messagesCollectionView.scrollToLastItem(animated: true)
                    }
                case .failure:
                    let errorMessage = Message(
                        sender: self.robot,
                        messageId: UUID().uuidString,
                        sentDate: Date(),
                        kind: .text("Sorry, I couldn't get a response. Please try again.")
                    )
                    self.messages.append(errorMessage)
                    self.messagesCollectionView.insertSections([self.messages.count - 1])
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            }
        }
    }

    @IBAction func cancelOnTap(_ sender: Any) {
        dismiss(animated: true)
    }
}
