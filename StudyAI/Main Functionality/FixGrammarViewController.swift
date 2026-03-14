//
//  FixGrammarViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/17/23.
//

import UIKit
import FirebaseFirestore
import FirebaseFunctions

class FixGrammarViewController: UIViewController, UITextViewDelegate, reloadUserDelegate {
    private let heroTag = 8_551

    @IBOutlet weak var fixGrammarButton: UIButton!
    @IBOutlet weak var tokens: UIButton!
    @IBOutlet weak var grammarTextView: UITextView!
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var helpButton: UIBarButtonItem!
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    
    
    func reload() {
        refreshAccessButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        view.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear

        self.setDoneOnKeyboard(textView: grammarTextView)
        self.setDoneOnKeyboard(textView: textView)

        UserService.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        let color = UIColor.init(red: 253/255, green: 229/255, blue: 65/255, alpha: 1)
                
        Utilities.styleFillButton2(fixGrammarButton, color: color)
        Utilities.styleHollowButton(tokens)
        tokens.titleLabel?.numberOfLines = 2
        tokens.titleLabel?.textAlignment = .center
        Utilities.styleTextView(grammarTextView, color: color)
        Utilities.styleTextView(textView, color: AIcademyTheme.magenta)
        label.textColor = AIcademyTheme.ink
        installHeroIfNeeded()
        refreshAccessButton()
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        guard let keyboardValue = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        var keyboardFrame: CGRect = keyboardValue.cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 150
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func makeCallToOpenAI(str:String){
        StudyAccessManager.shared.accessSnapshot(for: .grammar) { snapshot in
            DispatchQueue.main.async {
                guard snapshot.canUseFeature else {
                    self.presentUsageLimitAlert(
                        title: "Free Grammar Limit Reached",
                        message: "Free users get \(StudyAccessFeature.grammar.dailyFreeLimit) grammar passes per day. Upgrade to Premium for more help from Carlisle."
                    )
                    return
                }

                let confirmAlert = UIAlertController(
                    title: "Confirm Grammar Pass",
                    message: snapshot.confirmMessage(for: "Carlisle Grammar"),
                    preferredStyle: .alert
                )
                confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                confirmAlert.addAction(UIAlertAction(title: "Fix It", style: .default) { _ in
                    self.executeGrammarCall(str: str)
                })
                self.present(confirmAlert, animated: true)
            }
        }
    }

    private func executeGrammarCall(str: String) {
        let data : [String: Any] = [
            "message" : str, "max_tokens": 3000]
        let indicator = Indicator()
        indicator.showIndicator()
        indicator.alert.title = "Correcting grammar..."
        let funcGetData = Functions.functions().httpsCallable("getDataGrammar")
        funcGetData.timeoutInterval = 300000

        funcGetData.call(data) { (result, error) in
            if let _ = error {
                indicator.hideIndicator {
                    let cancel = UIAlertAction(title: "cancel", style: .cancel){ (action) in
                    }

                    let ac1 = UIAlertController(title: "Error", message: "Your request could not be processed.  Please try again.", preferredStyle: .alert)
                    ac1.addAction(cancel)
                    self.present(ac1, animated: true)
                    return
                }
            } else if let dict = result?.data as? [String:Any] {
                guard let exists = dict["info"] as? [String:Any], let _ = dict["max_tokens"] as? Int else{
                    indicator.hideIndicator(completion: nil)
                    return
                }

                guard let content = exists["content"] as? String else {
                    indicator.hideIndicator {
                        let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                        }

                        let ac1 = UIAlertController(title: "Error", message: "Your request could not be processed.  Please try again.", preferredStyle: .alert)
                        ac1.addAction(cancel)
                        self.present(ac1, animated: true)
                    }
                    return
                }

                let prefixIndex = min(35, max(0, content.count - 1))
                let prefix = String(content.prefix(prefixIndex))
                self.createTextView(content: content)
                DocumentService.putDocument(subject: "English", field: "Grammar", text: content, question: str, docType: "txt",questionType: "Fix Grammar", questionTopic: "\(String(prefix))...", indicator: indicator)
                StudyAccessManager.shared.recordSuccessfulUse(for: .grammar) {
                    DispatchQueue.main.async {
                        self.refreshAccessButton()
                    }
                }
            }
        }
    }
    
    func createTextView(content:String){
        textView.font = .systemFont(ofSize: 16)
        textView.text = content
        Utilities.styleTextView(textView, color: AIcademyTheme.magenta)
        self.adjustUITextViewHeight(arg: textView)
        let height = textView.height + label.height + grammarTextView.height + fixGrammarButton.height
        contentViewHeight.constant = 150 + height
        self.setDoneOnKeyboard(textView: textView)
    }
    
    func setDoneOnKeyboard(textView:UITextView) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textView.inputAccessoryView = keyboardToolbar
        grammarTextView.inputAccessoryView = keyboardToolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.isScrollEnabled = false
        arg.sizeToFit()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func tokensOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toPaywallVC", sender: self)
    }
    
    @IBAction func fixGrammarOnTap(_ sender: Any) {
        if grammarTextView.text == nil || grammarTextView.text == "" {
            let cancel = UIAlertAction(title: "cancel", style: .cancel){ (action) in
            }
            
            let ac1 = UIAlertController(title: "Error: No Text Input", message: "Please add a sentence, paragraph, or essay before you submit.", preferredStyle: .alert)
            ac1.addAction(cancel)
            self.present(ac1, animated: true)
            
            
        }
        else {
            makeCallToOpenAI(str: grammarTextView.text)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPaywallVC" {
            guard let viewcontroller = segue.destination as? PayWallViewController else { return }
            viewcontroller.segueID = "unwindToFix"
        }
    }
    
    @IBAction func unwindToFix(segue: UIStoryboardSegue){
        refreshAccessButton()
        
        }
    
    @IBAction func helpButtonOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toHelp", sender: self)
    }

    private func installHeroIfNeeded() {
        guard contentView.viewWithTag(heroTag) == nil else { return }

        let card = UIView(frame: CGRect(x: 16, y: 12, width: contentView.bounds.width - 32, height: 146))
        card.tag = heroTag
        card.autoresizingMask = [.flexibleWidth]
        AIcademyTheme.styleSurface(card, tint: AIcademyTheme.yellow)

        let imageView = UIImageView(frame: CGRect(x: 16, y: 20, width: 88, height: 88))
        Utilities.applyHeroImage(imageView)
        card.addSubview(imageView)

        let title = UILabel(frame: CGRect(x: 118, y: 24, width: card.bounds.width - 134, height: 30))
        title.autoresizingMask = [.flexibleWidth]
        title.text = "Grammar Glow-Up"
        AIcademyTheme.styleTitle(title, size: 26)
        card.addSubview(title)

        let subtitle = UILabel(frame: CGRect(x: 118, y: 58, width: card.bounds.width - 134, height: 52))
        subtitle.autoresizingMask = [.flexibleWidth]
        subtitle.numberOfLines = 0
        subtitle.text = "Drop in a sentence, paragraph, or essay and Carlisle will clean it up without making the page feel cramped."
        AIcademyTheme.styleSubtitle(subtitle, size: 14)
        card.addSubview(subtitle)

        contentView.addSubview(card)
        contentView.sendSubviewToBack(card)
        contentViewHeight.constant = max(contentViewHeight.constant, 560)
    }

    private func refreshAccessButton() {
        StudyAccessManager.shared.accessSnapshot(for: .grammar) { snapshot in
            DispatchQueue.main.async {
                self.tokens.setTitle(snapshot.buttonTitle, for: .normal)
            }
        }
    }

    private func presentUsageLimitAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Not Now", style: .cancel))
        alert.addAction(UIAlertAction(title: "Go Premium", style: .default) { _ in
            self.performSegue(withIdentifier: "toPaywallVC", sender: self)
        })
        present(alert, animated: true)
    }
    
}
