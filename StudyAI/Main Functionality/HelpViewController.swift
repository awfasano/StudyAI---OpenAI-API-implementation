//
//  HelpViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 6/3/23.
//

import UIKit

class HelpViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupScrollView()
        addHelpContent()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 40, right: 20)
        contentStack.isLayoutMarginsRelativeArrangement = true

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
    }

    private func addHelpContent() {
        addSection(title: "How to Use AIcademy", body: """
        1. Select a subject (Math, Science, History, etc.)
        2. Choose a specific field (e.g., Algebra, Biology)
        3. Pick a question type (Multiple Choice, Flashcards, etc.)
        4. Enter your topic (up to 50 characters)
        5. Tap Generate and wait for your content
        """)

        addSection(title: "Question Types", body: """
        Multiple Choice - Interactive questions with instant grading
        Flashcards - Flip cards with terms and definitions
        Practice Problems - Problems with detailed solutions
        Step-by-Step Guides - Concept explanations broken into steps
        Vocab Lists - Key terms with definitions
        Essay Topics - Writing prompts with example responses
        """)

        addSection(title: "GPT Models", body: """
        GPT-3.5 - Faster responses, uses fewer tokens (1x cost)
        GPT-4 - Higher quality responses, uses more tokens (15x cost)

        Toggle between models using the button in the top-right corner.
        """)

        addSection(title: "Tokens", body: """
        Tokens are used each time you generate content. The cost depends on the length of your request and the model used.

        You'll see an estimated token cost before each generation so there are no surprises.

        Verify your email to receive 50,000 free tokens. You can purchase additional tokens (250,000) from the Tokens button.
        """)

        addSection(title: "Chat Assistant", body: """
        Tap the chat icon to talk with Carlisle, your AI study assistant. Ask follow-up questions about generated content or get help with any topic.

        Chat uses GPT-4 for the best responses.
        """)

        addSection(title: "Past Questions", body: """
        All generated content is automatically saved. Access it from the Past Questions tab. You can sort by date, topic, or question type, and export any item as a PDF.
        """)

        addSection(title: "Grammar Tool", body: """
        Select English > Grammar to access the grammar correction tool. Paste any text and the AI will fix spelling and grammar errors.
        """)

        addSection(title: "Need Help?", body: """
        Contact us at anthony@aicademy.us
        """)
    }

    private func addSection(title: String, body: String) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 16)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(bodyLabel)
        contentStack.addArrangedSubview(separator)
    }

    @IBAction func cancelOnTap(_ sender: Any) {
        dismiss(animated: true)
    }
}
