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
    private let heroCard = UIView()
    private let heroTitle = UILabel()
    private let heroBody = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        setupScrollView()
        configureHero()
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
            scrollView.topAnchor.constraint(equalTo: heroCard.bottomAnchor, constant: 10),
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

    private func configureHero() {
        AIcademyTheme.styleSurface(heroCard)
        heroCard.translatesAutoresizingMaskIntoConstraints = false
        heroTitle.translatesAutoresizingMaskIntoConstraints = false
        heroBody.translatesAutoresizingMaskIntoConstraints = false
        AIcademyTheme.styleTitle(heroTitle, size: 28)
        heroTitle.text = "Need a hand?"
        heroBody.text = "Carlisle can guide users through prompts, reviews, and premium features without the app feeling dense."
        heroBody.font = .systemFont(ofSize: 17, weight: .medium)
        heroBody.numberOfLines = 0
        heroBody.textColor = AIcademyTheme.ink.withAlphaComponent(0.75)

        view.addSubview(heroCard)
        heroCard.addSubview(heroTitle)
        heroCard.addSubview(heroBody)

        NSLayoutConstraint.activate([
            heroCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            heroCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            heroCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            heroCard.heightAnchor.constraint(equalToConstant: 150),
            heroTitle.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 20),
            heroTitle.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),
            heroTitle.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -20),
            heroBody.topAnchor.constraint(equalTo: heroTitle.bottomAnchor, constant: 8),
            heroBody.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 20),
            heroBody.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -20),
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

        addSection(title: "Generation Modes", body: """
        Fast mode - Quicker generation for simple review material
        Deep mode - Richer generation for deeper explanations and study sheets

        Switch modes using the top-right button on the generator screen.
        """)

        addSection(title: "Premium", body: """
        Premium unlocks monthly or annual access for heavier study generation and more Carlisle help.

        Monthly and annual plans are available from the Premium screen, and purchases can be restored at any time.
        """)

        addSection(title: "Chat Assistant", body: """
        Tap the chat icon to talk with Carlisle, your AI study assistant. Ask follow-up questions about generated content or get help with any topic.

        Carlisle is best for quick clarifications, review help, and guided follow-up questions.
        """)

        addSection(title: "Past Questions", body: """
        All generated content is automatically saved. Access it from the Past Questions tab. You can sort by date, topic, or question type, and export any item as a PDF.
        """)

        addSection(title: "Grammar Tool", body: """
        Select English > Grammar to access the grammar correction tool. Paste any text and Carlisle will clean up spelling, grammar, and clarity.
        """)

        addSection(title: "Need Help?", body: """
        Contact us at anthony@aicademy.us
        """)
    }

    private func addSection(title: String, body: String) {
        let card = UIView()
        AIcademyTheme.styleSurface(card)
        card.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 20)
        titleLabel.textColor = AIcademyTheme.ink
        titleLabel.numberOfLines = 0

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 16)
        bodyLabel.textColor = AIcademyTheme.ink.withAlphaComponent(0.72)
        bodyLabel.numberOfLines = 0
        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
        ])

        contentStack.addArrangedSubview(card)
    }

    @IBAction func cancelOnTap(_ sender: Any) {
        dismiss(animated: true)
    }
}
