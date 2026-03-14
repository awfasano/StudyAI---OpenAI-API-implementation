//
//  Utilities.swift
//  Waited
//
//  Created by Anthony Fasano on 12/14/20.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

enum AIcademyRuntime {
    static var usesSwiftUIRoot = false
}

enum AIcademyTheme {
    static let ink = UIColor(red: 32/255, green: 18/255, blue: 53/255, alpha: 1)
    static let cyan = UIColor(red: 38/255, green: 232/255, blue: 247/255, alpha: 1)
    static let magenta = UIColor(red: 231/255, green: 35/255, blue: 247/255, alpha: 1)
    static let orange = UIColor(red: 255/255, green: 142/255, blue: 20/255, alpha: 1)
    static let yellow = UIColor(red: 255/255, green: 199/255, blue: 34/255, alpha: 1)
    static let surface = UIColor.white
    static let softSurface = UIColor(red: 251/255, green: 247/255, blue: 1, alpha: 0.96)
    static let border = UIColor(red: 41/255, green: 23/255, blue: 69/255, alpha: 0.12)

    static func applyBackground(to view: UIView) {
        let backgroundTag = 7_321
        if view.viewWithTag(backgroundTag) != nil { return }
        let background = AIcademyBackgroundView(frame: view.bounds)
        background.tag = backgroundTag
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(background, at: 0)
    }

    static func styleSurface(_ view: UIView, tint: UIColor? = nil) {
        view.backgroundColor = surface
        view.layer.cornerRadius = 28
        view.layer.borderWidth = 2
        view.layer.borderColor = (tint ?? border).cgColor
        view.layer.shadowColor = ink.cgColor
        view.layer.shadowOpacity = 0.12
        view.layer.shadowRadius = 18
        view.layer.shadowOffset = CGSize(width: 0, height: 12)
    }

    static func styleTitle(_ label: UILabel, size: CGFloat) {
        label.font = UIFont.systemFont(ofSize: size, weight: .heavy)
        label.textColor = ink
    }

    static func styleSubtitle(_ label: UILabel, size: CGFloat = 16) {
        label.font = UIFont.systemFont(ofSize: size, weight: .semibold)
        label.textColor = ink.withAlphaComponent(0.72)
    }
}

final class AIcademyBackgroundView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = UIColor(red: 1, green: 250/255, blue: 238/255, alpha: 1)

        let bubbleSpecs: [(UIColor, CGRect)] = [
            (AIcademyTheme.yellow, CGRect(x: 18, y: 58, width: 120, height: 120)),
            (AIcademyTheme.cyan, CGRect(x: 210, y: 120, width: 82, height: 82)),
            (AIcademyTheme.orange, CGRect(x: -12, y: 330, width: 96, height: 96)),
            (AIcademyTheme.magenta, CGRect(x: 270, y: 460, width: 110, height: 110)),
        ]

        for (color, frame) in bubbleSpecs {
            let bubble = UIView(frame: frame)
            bubble.backgroundColor = color.withAlphaComponent(0.92)
            bubble.layer.cornerRadius = frame.width / 2
            addSubview(bubble)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum StudyAccessFeature {
    case generator
    case grammar

    var dailyFreeLimit: Int {
        switch self {
        case .generator:
            return 3
        case .grammar:
            return 2
        }
    }

    var counterField: String {
        switch self {
        case .generator:
            return "dailyGenerationCount"
        case .grammar:
            return "dailyGrammarCount"
        }
    }

    var buttonTitle: String {
        switch self {
        case .generator:
            return "Free study sessions"
        case .grammar:
            return "Free grammar passes"
        }
    }
}

struct StudyAccessSnapshot {
    let isPremium: Bool
    let remainingFreeUses: Int
    let dailyLimit: Int

    var canUseFeature: Bool {
        isPremium || remainingFreeUses > 0
    }

    var buttonTitle: String {
        if isPremium {
            return "Premium Active"
        }
        return "Free: \(remainingFreeUses) Left"
    }

    func confirmMessage(for modeName: String) -> String {
        if isPremium {
            return "Mode: \(modeName)\nPlan: Premium\nAccess: Unlimited generation"
        }
        return "Mode: \(modeName)\nPlan: Free\nThis will use 1 of your \(dailyLimit) daily free sessions. Remaining right now: \(remainingFreeUses)"
    }
}

final class StudyAccessManager {
    static let shared = StudyAccessManager()

    private let db = Firestore.firestore()
    private let dateField = "dailyUsageDate"

    private init() {}

    func accessSnapshot(for feature: StudyAccessFeature, completion: @escaping (StudyAccessSnapshot) -> Void) {
        IAPManager.shared.getSubscriptionStatus { isPremium in
            if isPremium {
                completion(StudyAccessSnapshot(isPremium: true, remainingFreeUses: feature.dailyFreeLimit, dailyLimit: feature.dailyFreeLimit))
                return
            }

            guard let userId = Auth.auth().currentUser?.uid ?? (UserService.user.id.isEmpty ? nil : UserService.user.id) else {
                completion(StudyAccessSnapshot(isPremium: false, remainingFreeUses: feature.dailyFreeLimit, dailyLimit: feature.dailyFreeLimit))
                return
            }

            self.db.collection("users").document(userId).getDocument { snapshot, _ in
                let data = snapshot?.data() ?? [:]
                let today = Self.todayKey()
                let storedDate = data[self.dateField] as? String
                let currentCount = storedDate == today ? (data[feature.counterField] as? Int ?? 0) : 0
                let remaining = max(0, feature.dailyFreeLimit - currentCount)
                completion(StudyAccessSnapshot(isPremium: false, remainingFreeUses: remaining, dailyLimit: feature.dailyFreeLimit))
            }
        }
    }

    func recordSuccessfulUse(for feature: StudyAccessFeature, completion: (() -> Void)? = nil) {
        IAPManager.shared.getSubscriptionStatus { isPremium in
            guard !isPremium else {
                completion?()
                return
            }

            guard let userId = Auth.auth().currentUser?.uid ?? (UserService.user.id.isEmpty ? nil : UserService.user.id) else {
                completion?()
                return
            }

            let userRef = self.db.collection("users").document(userId)
            userRef.getDocument { snapshot, _ in
                let data = snapshot?.data() ?? [:]
                let today = Self.todayKey()
                let storedDate = data[self.dateField] as? String
                let currentCount = storedDate == today ? (data[feature.counterField] as? Int ?? 0) : 0

                var update: [String: Any] = [
                    self.dateField: today,
                    feature.counterField: currentCount + 1
                ]

                if storedDate != today {
                    let otherField = feature == .generator ? StudyAccessFeature.grammar.counterField : StudyAccessFeature.generator.counterField
                    update[otherField] = 0
                }

                userRef.setData(update, merge: true) { _ in
                    completion?()
                }
            }
        }
    }

    private static func todayKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

class Utilities {
    
    
    static func styleTextField(_ textfield:UITextField, color: UIColor?){
        textfield.borderStyle = .none
        textfield.backgroundColor = AIcademyTheme.softSurface
        textfield.layer.cornerRadius = 18
        textfield.layer.borderWidth = 2
        textfield.layer.borderColor = (color ?? AIcademyTheme.border).cgColor
        textfield.layer.shadowColor = AIcademyTheme.ink.cgColor
        textfield.layer.shadowOpacity = 0.06
        textfield.layer.shadowRadius = 12
        textfield.layer.shadowOffset = CGSize(width: 0, height: 6)
        let padding = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textfield.leftView = padding
        textfield.leftViewMode = .always
    }

    static func styleTextView(_ textView: UITextView, color: UIColor?) {
        textView.backgroundColor = AIcademyTheme.softSurface
        textView.layer.cornerRadius = 22
        textView.layer.borderWidth = 2
        textView.layer.borderColor = (color ?? AIcademyTheme.border).cgColor
        textView.layer.shadowColor = AIcademyTheme.ink.cgColor
        textView.layer.shadowOpacity = 0.06
        textView.layer.shadowRadius = 12
        textView.layer.shadowOffset = CGSize(width: 0, height: 6)
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        textView.textColor = AIcademyTheme.ink
    }
    
    static func styleFillButton(_ button:UIButton) {
        button.backgroundColor = AIcademyTheme.ink
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.height/2
        if button.layer.cornerRadius == 0 { button.layer.cornerRadius = 20 }
        button.layer.borderWidth = 2
        button.layer.borderColor = AIcademyTheme.ink.cgColor
        button.layer.shadowColor = AIcademyTheme.magenta.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 14
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.tintColor = UIColor.white
        
    }
    static func styleFillButton2(_ button:UIButton, color: UIColor) {
        button.backgroundColor = color
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = button.frame.height/2
        if button.layer.cornerRadius == 0 { button.layer.cornerRadius = 20 }
        button.layer.borderWidth = 2
        button.layer.borderColor = AIcademyTheme.ink.cgColor
        button.layer.shadowColor = AIcademyTheme.orange.cgColor
        button.layer.shadowOpacity = 0.18
        button.layer.shadowRadius = 14
        button.layer.shadowOffset = CGSize(width: 0, height: 10)
        button.tintColor = UIColor.white

        
    }
    
    static func styleHollowButton(_ button: UIButton) {
        button.layer.borderWidth = 2
        button.backgroundColor = AIcademyTheme.surface
        button.layer.borderColor = AIcademyTheme.ink.cgColor
        button.layer.cornerRadius = button.frame.height/2
        if button.layer.cornerRadius == 0 { button.layer.cornerRadius = 20 }
        button.setTitleColor(AIcademyTheme.ink, for: .normal)
        button.tintColor = AIcademyTheme.ink
    }

    static func styleLinkButton(_ button: UIButton) {
        button.setTitleColor(AIcademyTheme.magenta, for: .normal)
        button.tintColor = AIcademyTheme.magenta
    }

    static func applyHeroImage(_ imageView: UIImageView) {
        imageView.image = UIImage(named: "appicon.jpeg")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = AIcademyTheme.surface
        imageView.layer.cornerRadius = 28
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = AIcademyTheme.border.cgColor
        imageView.layer.shadowColor = AIcademyTheme.ink.cgColor
        imageView.layer.shadowOpacity = 0.14
        imageView.layer.shadowRadius = 18
        imageView.layer.shadowOffset = CGSize(width: 0, height: 12)
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
}


public protocol ImagePickerDelegate: AnyObject {
    func didSelect(image: UIImage?)
}



open class ImagePicker: NSObject {

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?

    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()

        super.init()

        self.presentationController = presentationController
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        self.pickerController.mediaTypes = ["public.image"]
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView) {

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Take photo") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
}

extension ImagePicker: UINavigationControllerDelegate {

}
