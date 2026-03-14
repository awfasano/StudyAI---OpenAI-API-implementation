//
//  ViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/14/23.
//

import UIKit
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class ViewInitialController: UIViewController {
    
    
    @IBOutlet weak var logo: UIImageView!
    
    @IBOutlet weak var signUp: UIButton!
    
    @IBOutlet weak var signIn: UIButton!
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        Utilities.styleFillButton(signUp)
        Utilities.styleHollowButton(signIn)
        Utilities.applyHeroImage(logo)
        AIcademyTheme.styleTitle(titleLabel, size: 32)
        titleLabel.text = "Meet Carlisle"
        titleLabel.textAlignment = .center
        subtitleLabel.text = "Turn any topic into bright, interactive study material."
        subtitleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        subtitleLabel.textColor = AIcademyTheme.ink.withAlphaComponent(0.78)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        // Do any additional setup after loading the view.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.frame = CGRect(x: 28, y: logo.frame.maxY + 12, width: view.bounds.width - 56, height: 44)
        subtitleLabel.frame = CGRect(x: 34, y: titleLabel.frame.maxY + 6, width: view.bounds.width - 68, height: 48)
    }
    
    @IBAction func logInOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toSignIn", sender: self)
    }
    @IBAction func signUpOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toSignUp", sender: self)
    }
}

@MainActor
final class AIcademyAppSession: ObservableObject {
    static let shared = AIcademyAppSession()

    enum AuthState {
        case loading
        case signedOut
        case signedIn
    }

    @Published var authState: AuthState = .loading
    @Published var isPremium = false

    private var authListener: AuthStateDidChangeListenerHandle?

    private init() {
        start()
    }

    func start() {
        guard authListener == nil else { return }

        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            DispatchQueue.main.async {
                self.handleAuthState(user)
            }
        }
    }

    func refreshPremium() {
        IAPManager.shared.getSubscriptionStatus { isPremium in
            DispatchQueue.main.async {
                self.isPremium = isPremium
            }
        }
    }

    func signOut() {
        UserService.userListener?.remove()
        KeychainHelper.shared.save(false, forKey: "premium")
        try? Auth.auth().signOut()
        UserService.user = User()
        isPremium = false
        authState = .signedOut
    }

    private func handleAuthState(_ user: FirebaseAuth.User?) {
        guard let user else {
            UserService.userListener?.remove()
            UserService.user = User()
            isPremium = false
            authState = .signedOut
            return
        }

        _ = user
        UserService.getCurrentUser()
        refreshPremium()
        authState = .signedIn
    }
}

struct AIcademyRootView: View {
    @StateObject private var session = AIcademyAppSession.shared

    var body: some View {
        Group {
            switch session.authState {
            case .loading:
                AIcademyLoadingView()
            case .signedOut:
                AIcademyAuthRootView()
            case .signedIn:
                AIcademyMainShellView()
            }
        }
        .environmentObject(session)
    }
}

struct AIcademyLoadingView: View {
    var body: some View {
        ZStack {
            AIcademySwiftUIBackground()

            VStack(spacing: 22) {
                AIcademyCarlisleMark(size: 128)
                ProgressView()
                    .tint(Color(uiColor: AIcademyTheme.ink))
                Text("Loading AIcademy")
                    .font(.system(size: 22, weight: .heavy))
                    .foregroundStyle(Color(uiColor: AIcademyTheme.ink))
            }
            .padding(32)
        }
    }
}

struct AIcademyAuthRootView: View {
    var body: some View {
        NavigationView {
            ZStack {
                AIcademySwiftUIBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer(minLength: 24)

                        AIcademyCarlisleMark(size: 170)

                        VStack(spacing: 10) {
                            Text("Study Smarter With Carlisle")
                                .font(.system(size: 34, weight: .black))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color(uiColor: AIcademyTheme.ink))

                            Text("Turn any topic into quizzes, flashcards, grammar help, and follow-up explanations in a brighter, simpler workspace.")
                                .font(.system(size: 17, weight: .semibold))
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color(uiColor: AIcademyTheme.ink).opacity(0.76))
                        }
                        .padding(.horizontal, 24)

                        VStack(spacing: 14) {
                            NavigationLink {
                                AIcademyLoginView()
                            } label: {
                                Text("Sign In")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(AIcademyFilledButtonStyle())

                            NavigationLink {
                                AIcademySignUpView()
                            } label: {
                                Text("Create Account")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(AIcademyOutlineButtonStyle())
                        }
                        .padding(.horizontal, 24)

                        VStack(spacing: 12) {
                            AIcademyFeatureRow(title: "Flexible study generation", subtitle: "Build quizzes, flashcards, and review material from one focused prompt.")
                            AIcademyFeatureRow(title: "Carlisle follow-up help", subtitle: "Ask grounded questions while you review instead of leaving the screen.")
                            AIcademyFeatureRow(title: "Premium when you need more", subtitle: "Free daily access gets you started, and Premium unlocks fuller use.")
                        }
                        .padding(.horizontal, 24)

                        Spacer(minLength: 28)
                    }
                    .padding(.vertical, 28)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
    }
}

struct AIcademyLoginView: View {
    @EnvironmentObject private var session: AIcademyAppSession
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showingResetConfirmation = false

    var body: some View {
        ZStack {
            AIcademySwiftUIBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    AIcademyCarlisleMark(size: 120)

                    AIcademyAuthCard(title: "Welcome back", subtitle: "Sign in to open your study workspace and restore Premium access.") {
                        VStack(spacing: 14) {
                            AIcademyTextField(title: "Email", text: $email, keyboardType: .emailAddress, autocapitalization: .never)
                            AIcademySecureField(title: "Password", text: $password)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(uiColor: AIcademyTheme.magenta))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button("Sign In") {
                                signIn()
                            }
                            .buttonStyle(AIcademyFilledButtonStyle())
                            .disabled(isLoading)

                            Button("Send Password Reset") {
                                sendPasswordReset()
                            }
                            .buttonStyle(AIcademyOutlineButtonStyle())
                            .disabled(isLoading)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 30)
            }
        }
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isLoading {
                AIcademyBlockingProgressView(title: "Signing in")
            }
        }
        .alert("Password Reset Email Sent", isPresented: $showingResetConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please check your email for a password reset link.")
        }
        .onAppear {
            session.refreshPremium()
        }
    }

    private func signIn() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = "Please enter email and password."
            return
        }

        errorMessage = ""
        isLoading = true

        Auth.auth().signIn(withEmail: trimmedEmail, password: trimmedPassword) { _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error {
                    errorMessage = error.localizedDescription
                    return
                }

                UserService.getCurrentUser()
                session.refreshPremium()
            }
        }
    }

    private func sendPasswordReset() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Please enter your email address first."
            return
        }

        errorMessage = ""
        isLoading = true

        Auth.auth().sendPasswordReset(withEmail: trimmedEmail) { error in
            DispatchQueue.main.async {
                isLoading = false
                if let error {
                    errorMessage = error.localizedDescription
                } else {
                    showingResetConfirmation = true
                }
            }
        }
    }
}

struct AIcademySignUpView: View {
    @EnvironmentObject private var session: AIcademyAppSession
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            AIcademySwiftUIBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    AIcademyCarlisleMark(size: 120)

                    AIcademyAuthCard(title: "Create your AIcademy account", subtitle: "Start on the free plan and upgrade to Premium whenever you need fuller daily access.") {
                        VStack(spacing: 14) {
                            AIcademyTextField(title: "First name", text: $firstName, autocapitalization: .words)
                            AIcademyTextField(title: "Last name", text: $lastName, autocapitalization: .words)
                            AIcademyTextField(title: "Email", text: $email, keyboardType: .emailAddress, autocapitalization: .never)
                            AIcademySecureField(title: "Password", text: $password)
                            AIcademySecureField(title: "Confirm password", text: $confirmPassword)

                            VStack(alignment: .leading, spacing: 6) {
                                AIcademyRequirementRow(text: "At least 8 characters", isMet: password.count >= 8)
                                AIcademyRequirementRow(text: "At least 1 number", isMet: password.rangeOfCharacter(from: .decimalDigits) != nil)
                                AIcademyRequirementRow(text: "At least 1 special character", isMet: password.range(of: #"[$@$#!%*?&]"#, options: .regularExpression) != nil)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 2)

                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(uiColor: AIcademyTheme.magenta))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            if !successMessage.isEmpty {
                                Text(successMessage)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color(uiColor: AIcademyTheme.ink))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            Button("Create Account") {
                                createAccount()
                            }
                            .buttonStyle(AIcademyFilledButtonStyle())
                            .disabled(isLoading)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 30)
            }
        }
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if isLoading {
                AIcademyBlockingProgressView(title: "Creating account")
            }
        }
        .onAppear {
            session.refreshPremium()
        }
    }

    private func createAccount() {
        let trimmedFirst = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLast = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirmation = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedFirst.isEmpty, !trimmedLast.isEmpty, !trimmedEmail.isEmpty, !trimmedPassword.isEmpty, !trimmedConfirmation.isEmpty else {
            errorMessage = "Please fill in all fields."
            successMessage = ""
            return
        }

        guard Utilities.isPasswordValid(trimmedPassword) else {
            errorMessage = "Please use at least 8 characters, a number, and a special character."
            successMessage = ""
            return
        }

        guard trimmedPassword == trimmedConfirmation else {
            errorMessage = "Passwords do not match."
            successMessage = ""
            return
        }

        errorMessage = ""
        successMessage = ""
        isLoading = true

        Auth.auth().createUser(withEmail: trimmedEmail, password: trimmedPassword) { result, error in
            if let error {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
                return
            }

            guard let user = result?.user else {
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = "Unable to create your account right now."
                }
                return
            }

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let userData: [String: Any] = [
                "firstName": trimmedFirst,
                "lastName": trimmedLast,
                "email": trimmedEmail,
                "uid": user.uid,
                "stripeID": "",
                "subscribed": false,
                "subscriptionStatus": "free",
                "plan": "free",
                "tokensRemaining": 0,
                "tokensMonthly": 0,
                "receivedTokens": true,
                "dailyUsageDate": formatter.string(from: Date()),
                "dailyGenerationCount": 0,
                "dailyGrammarCount": 0
            ]

            Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                if let error {
                    DispatchQueue.main.async {
                        isLoading = false
                        errorMessage = error.localizedDescription
                    }
                    return
                }

                user.sendEmailVerification { verificationError in
                    DispatchQueue.main.async {
                        isLoading = false
                        UserService.getCurrentUser()
                        session.refreshPremium()

                        if let verificationError {
                            errorMessage = verificationError.localizedDescription
                        } else {
                            successMessage = "Verification email sent. You can start using AIcademy now and verify your email afterward."
                        }
                    }
                }
            }
        }
    }
}

struct AIcademyMainShellView: View {
    @EnvironmentObject private var session: AIcademyAppSession
    @State private var selectedTab = AIcademyShellTab.study
    @State private var modalRoute: AIcademyShellModalRoute?
    @State private var showingPaywall = false

    var body: some View {
        ZStack(alignment: .bottom) {
            AIcademySwiftUIBackground()

            VStack(spacing: 16) {
                AIcademyShellHeaderCard(
                    selectedTab: selectedTab,
                    isPremium: session.isPremium,
                    openHelp: { modalRoute = .help },
                    openGrammar: { modalRoute = .grammar },
                    openPaywall: { showingPaywall = true }
                )
                .padding(.horizontal, 18)
                .padding(.top, 12)

                selectedContent
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
                    )
                    .shadow(color: Color(uiColor: AIcademyTheme.ink).opacity(0.12), radius: 22, y: 12)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 108)
            }

            AIcademyShellTabBar(selectedTab: $selectedTab)
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
        }
        .sheet(item: $modalRoute) { route in
            AIcademySheetNavigationContainer(identifier: route.identifier, title: route.title)
        }
        .sheet(isPresented: $showingPaywall) {
            AIcademyStandaloneNavigationContainer(title: "Premium") {
                let controller = PayWallViewController()
                controller.segueID = nil
                return controller
            }
        }
        .onAppear {
            session.refreshPremium()
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .study:
            AIcademyStoryboardNavigationContainer(identifier: "subjectVC")
        case .history:
            AIcademyStoryboardNavigationContainer(identifier: "pastCallsVC")
        case .profile:
            AIcademyStoryboardNavigationContainer(identifier: "profileVC")
        }
    }
}

enum AIcademyShellModalRoute: String, Identifiable {
    case grammar
    case help

    var id: String { rawValue }

    var identifier: String {
        switch self {
        case .grammar:
            return "grammarVC"
        case .help:
            return "helpVC"
        }
    }

    var title: String {
        switch self {
        case .grammar:
            return "Grammar"
        case .help:
            return "Help"
        }
    }
}

enum AIcademyShellTab: Hashable {
    case study
    case history
    case profile

    var title: String {
        switch self {
        case .study:
            return "Study Workspace"
        case .history:
            return "Past Questions"
        case .profile:
            return "Profile"
        }
    }

    var subtitle: String {
        switch self {
        case .study:
            return "Choose a subject, generate study material, and keep Carlisle close by."
        case .history:
            return "Reopen saved material, review old work, and continue where you left off."
        case .profile:
            return "Manage your account, Premium access, and support links in one place."
        }
    }

    var symbol: String {
        switch self {
        case .study:
            return "books.vertical.fill"
        case .history:
            return "clock.arrow.circlepath"
        case .profile:
            return "person.crop.circle.fill"
        }
    }

    var accent: UIColor {
        switch self {
        case .study:
            return AIcademyTheme.cyan
        case .history:
            return AIcademyTheme.orange
        case .profile:
            return AIcademyTheme.magenta
        }
    }
}

struct AIcademyShellHeaderCard: View {
    let selectedTab: AIcademyShellTab
    let isPremium: Bool
    let openHelp: () -> Void
    let openGrammar: () -> Void
    let openPaywall: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("AIcademy")
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(Color(uiColor: AIcademyTheme.ink))

                        AIcademyPlanPill(isPremium: isPremium)
                    }

                    Text(selectedTab.title)
                        .font(.system(size: 19, weight: .heavy))
                        .foregroundStyle(Color(uiColor: selectedTab.accent))

                    Text(selectedTab.subtitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color(uiColor: AIcademyTheme.ink).opacity(0.72))
                }

                Spacer(minLength: 8)

                AIcademyCarlisleMark(size: 82)
            }

            HStack(spacing: 10) {
                Button(selectedTab == .study ? "Quick Grammar" : "Help Center") {
                    if selectedTab == .study {
                        openGrammar()
                    } else {
                        openHelp()
                    }
                }
                .buttonStyle(AIcademyOutlineButtonStyle())

                Button(isPremium ? "Premium Active" : "Go Premium") {
                    if isPremium {
                        openHelp()
                    } else {
                        openPaywall()
                    }
                }
                .buttonStyle(AIcademyFilledButtonStyle(fillColor: isPremium ? AIcademyTheme.cyan : AIcademyTheme.magenta))
            }
        }
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
        )
        .shadow(color: Color(uiColor: AIcademyTheme.ink).opacity(0.12), radius: 20, y: 12)
    }
}

struct AIcademyPlanPill: View {
    let isPremium: Bool

    var body: some View {
        Text(isPremium ? "Premium" : "Free")
            .font(.system(size: 12, weight: .black))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(uiColor: isPremium ? AIcademyTheme.cyan : AIcademyTheme.ink))
            .clipShape(Capsule())
    }
}

struct AIcademyShellTabBar: View {
    @Binding var selectedTab: AIcademyShellTab

    var body: some View {
        HStack(spacing: 10) {
            ForEach([AIcademyShellTab.study, .history, .profile], id: \.self) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 18, weight: .bold))
                        Text(tab == .study ? "Study" : tab == .history ? "History" : "Profile")
                            .font(.system(size: 12, weight: .black))
                    }
                    .foregroundStyle(Color(uiColor: selectedTab == tab ? .white : AIcademyTheme.ink))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(uiColor: selectedTab == tab ? tab.accent : AIcademyTheme.softSurface))
                    )
                }
            }
        }
        .padding(10)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
        )
        .shadow(color: Color(uiColor: AIcademyTheme.ink).opacity(0.12), radius: 18, y: 10)
    }
}

struct AIcademySheetNavigationContainer: UIViewControllerRepresentable {
    let identifier: String
    let title: String?

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        if let title, controller.title?.isEmpty != false {
            controller.title = title
        }
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: context.coordinator,
            action: #selector(Coordinator.closeTapped)
        )
        let navigationController = UINavigationController(rootViewController: controller)
        context.coordinator.navigationController = navigationController
        AIcademyStoryboardNavigationContainer.applyAppearance(to: navigationController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }

    final class Coordinator: NSObject {
        weak var navigationController: UINavigationController?

        @objc func closeTapped() {
            navigationController?.dismiss(animated: true)
        }
    }
}

struct AIcademyStandaloneNavigationContainer: UIViewControllerRepresentable {
    let title: String?
    let makeController: () -> UIViewController

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let controller = makeController()
        if let title, controller.title?.isEmpty != false {
            controller.title = title
        }
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: context.coordinator,
            action: #selector(Coordinator.closeTapped)
        )
        let navigationController = UINavigationController(rootViewController: controller)
        context.coordinator.navigationController = navigationController
        AIcademyStoryboardNavigationContainer.applyAppearance(to: navigationController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }

    final class Coordinator: NSObject {
        weak var navigationController: UINavigationController?

        @objc func closeTapped() {
            navigationController?.dismiss(animated: true)
        }
    }
}

struct AIcademyStoryboardNavigationContainer: UIViewControllerRepresentable {
    let identifier: String

    func makeUIViewController(context: Context) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: identifier)
        let navigationController = UINavigationController(rootViewController: controller)
        Self.applyAppearance(to: navigationController)
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }

    static func applyAppearance(to navigationController: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AIcademyTheme.surface
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: AIcademyTheme.ink]
        appearance.largeTitleTextAttributes = [.foregroundColor: AIcademyTheme.ink]

        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        navigationController.navigationBar.compactAppearance = appearance
        navigationController.navigationBar.tintColor = AIcademyTheme.ink
        navigationController.navigationBar.prefersLargeTitles = false
    }
}

struct AIcademySwiftUIBackground: View {
    var body: some View {
        ZStack {
            Color(red: 1.0, green: 250.0 / 255.0, blue: 238.0 / 255.0)
                .ignoresSafeArea()

            Circle()
                .fill(Color(uiColor: AIcademyTheme.yellow).opacity(0.92))
                .frame(width: 150, height: 150)
                .offset(x: -120, y: -280)

            Circle()
                .fill(Color(uiColor: AIcademyTheme.cyan).opacity(0.95))
                .frame(width: 96, height: 96)
                .offset(x: 118, y: -220)

            Circle()
                .fill(Color(uiColor: AIcademyTheme.orange).opacity(0.94))
                .frame(width: 104, height: 104)
                .offset(x: -145, y: 16)

            Circle()
                .fill(Color(uiColor: AIcademyTheme.magenta).opacity(0.9))
                .frame(width: 140, height: 140)
                .offset(x: 150, y: 248)
        }
    }
}

struct AIcademyCarlisleMark: View {
    let size: CGFloat

    var body: some View {
        Group {
            if let image = UIImage(named: "transparentIcon.png") ?? UIImage(named: "appicon.jpeg") {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "sparkles")
                    .resizable()
                    .scaledToFit()
                    .padding(28)
                    .foregroundStyle(Color(uiColor: AIcademyTheme.ink))
            }
        }
        .frame(width: size, height: size)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
        )
        .shadow(color: Color(uiColor: AIcademyTheme.ink).opacity(0.14), radius: 18, y: 12)
    }
}

struct AIcademyFeatureRow: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(Color(uiColor: AIcademyTheme.ink))

            Text(subtitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(uiColor: AIcademyTheme.ink).opacity(0.74))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
        )
        .shadow(color: Color(uiColor: AIcademyTheme.ink).opacity(0.08), radius: 14, y: 10)
    }
}

struct AIcademyAuthCard<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 28, weight: .black))
                    .foregroundStyle(Color(uiColor: AIcademyTheme.ink))

                Text(subtitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color(uiColor: AIcademyTheme.ink).opacity(0.74))
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
        )
        .shadow(color: Color(uiColor: AIcademyTheme.ink).opacity(0.12), radius: 18, y: 12)
    }
}

struct AIcademyTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization? = .sentences

    var body: some View {
        TextField(title, text: $text)
            .textInputAutocapitalization(autocapitalization)
            .keyboardType(keyboardType)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(Color(uiColor: AIcademyTheme.softSurface))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
            )
            .foregroundStyle(Color(uiColor: AIcademyTheme.ink))
    }
}

struct AIcademySecureField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .padding(.horizontal, 16)
            .frame(height: 54)
            .background(Color(uiColor: AIcademyTheme.softSurface))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
            )
            .foregroundStyle(Color(uiColor: AIcademyTheme.ink))
    }
}

struct AIcademyRequirementRow: View {
    let text: String
    let isMet: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isMet ? Color(uiColor: AIcademyTheme.cyan) : Color(uiColor: AIcademyTheme.ink).opacity(0.4))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(uiColor: AIcademyTheme.ink).opacity(0.78))
        }
    }
}

struct AIcademyBlockingProgressView: View {
    let title: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.14)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                ProgressView()
                    .tint(Color(uiColor: AIcademyTheme.ink))
                Text(title)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(Color(uiColor: AIcademyTheme.ink))
            }
            .padding(.horizontal, 26)
            .padding(.vertical, 22)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
            )
        }
    }
}

struct AIcademyFilledButtonStyle: ButtonStyle {
    var fillColor: UIColor = AIcademyTheme.ink

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .heavy))
            .foregroundStyle(Color.white)
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(Color(uiColor: fillColor))
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .shadow(color: Color(uiColor: fillColor).opacity(0.2), radius: 12, y: 8)
    }
}

struct AIcademyOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .heavy))
            .foregroundStyle(Color(uiColor: AIcademyTheme.ink))
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(Color.white.opacity(configuration.isPressed ? 0.9 : 1))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(Color(uiColor: AIcademyTheme.border), lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
    }
}
