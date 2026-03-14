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
    private let headerCard = UIView()
    private let headerImageView = UIImageView()
    private let headerTitle = UILabel()
    private let headerBody = UILabel()

    let currentUser = Sender(photoURL: "", senderId: "self", displayName: "You")
    let robot = Sender(photoURL: "", senderId: "other", displayName: "Carlisle")

    var currentSender: SenderType { currentUser }

    private var messages: [Message] = []
    private var chatHistory: [[String: String]] = []
    private var awaitingResponse = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 1, green: 250/255, blue: 238/255, alpha: 1)
        configureHeader()
        configureComposer()
        configureMessages()

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
            kind: .text("Hi! I’m Carlisle. Ask about the study material on this screen and I’ll help you work through it.")
        )
        messages.append(welcomeMessage)
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }

    private func configureHeader() {
        headerCard.translatesAutoresizingMaskIntoConstraints = false
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerBody.translatesAutoresizingMaskIntoConstraints = false

        AIcademyTheme.styleSurface(headerCard, tint: AIcademyTheme.cyan)
        Utilities.applyHeroImage(headerImageView)
        AIcademyTheme.styleTitle(headerTitle, size: 24)
        headerTitle.text = "Ask Carlisle"
        headerBody.numberOfLines = 0
        AIcademyTheme.styleSubtitle(headerBody, size: 14)
        headerBody.text = "Quick follow-up help lives here, without pushing the actual study material offscreen."

        view.addSubview(headerCard)
        headerCard.addSubview(headerImageView)
        headerCard.addSubview(headerTitle)
        headerCard.addSubview(headerBody)

        NSLayoutConstraint.activate([
            headerCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            headerCard.heightAnchor.constraint(equalToConstant: 104),

            headerImageView.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            headerImageView.centerYAnchor.constraint(equalTo: headerCard.centerYAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 64),
            headerImageView.heightAnchor.constraint(equalToConstant: 64),

            headerTitle.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 18),
            headerTitle.leadingAnchor.constraint(equalTo: headerImageView.trailingAnchor, constant: 14),
            headerTitle.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),

            headerBody.topAnchor.constraint(equalTo: headerTitle.bottomAnchor, constant: 6),
            headerBody.leadingAnchor.constraint(equalTo: headerTitle.leadingAnchor),
            headerBody.trailingAnchor.constraint(equalTo: headerTitle.trailingAnchor)
        ])
    }

    private func configureComposer() {
        messageInputBar.backgroundView.backgroundColor = .clear
        messageInputBar.inputTextView.backgroundColor = AIcademyTheme.surface
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.inputTextView.layer.borderWidth = 2
        messageInputBar.inputTextView.layer.borderColor = AIcademyTheme.border.cgColor
        messageInputBar.inputTextView.textColor = AIcademyTheme.ink
        messageInputBar.inputTextView.placeholder = "Ask about this study material..."
        messageInputBar.sendButton.setTitle("Send", for: .normal)
        messageInputBar.sendButton.setTitleColor(AIcademyTheme.magenta, for: .normal)
    }

    private func configureMessages() {
        messagesCollectionView.backgroundColor = .clear
        messagesCollectionView.contentInset.top = 116
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard !awaitingResponse else { return }

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

        awaitingResponse = true
        messageInputBar.sendButton.isEnabled = false

        MessageService.sendMessage(messages: chatHistory) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.awaitingResponse = false
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

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message)
            ? AIcademyTheme.magenta
            : AIcademyTheme.surface
    }

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : AIcademyTheme.ink
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) {
            avatarView.backgroundColor = AIcademyTheme.ink
            avatarView.set(avatar: Avatar(initials: "Y"))
        } else {
            avatarView.backgroundColor = .clear
            avatarView.image = UIImage(named: "appicon.jpeg")
        }
    }
}
