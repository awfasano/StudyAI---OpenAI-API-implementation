//
//  FixGrammarViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/17/23.
//

import UIKit
import Firebase

class FixGrammarViewController: UIViewController, UITextViewDelegate, reloadUserDelegate {

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
        let tokensFormatted = DocumentService.formatNumber(UserService.user.tokensRemaining)
        tokens.setTitle("Tokens: \(tokensFormatted)", for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        grammarTextView.backgroundColor = UIColor.init(red: 253/255, green: 229/255, blue: 65/255, alpha: 1).withAlphaComponent(0.5)
        
        self.setDoneOnKeyboard(textView: grammarTextView)
        self.setDoneOnKeyboard(textView: textView)

        UserService.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        let color = UIColor.init(red: 253/255, green: 229/255, blue: 65/255, alpha: 1)
                
        let tokensFormatted = DocumentService.formatNumber(UserService.user.tokensRemaining)
         tokens.setTitle("Tokens: \(tokensFormatted)", for: .normal)
        
        Utilities.styleFillButton2(fixGrammarButton, color: color)
        // Do any additional setup after loading the view.
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
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
        
        let tokenQuestions = Int(Double(str.count)/4.0)
        var maxTokens = UserService.user.tokensRemaining-2*tokenQuestions
        
        if maxTokens < 0 {
            let cancel = UIAlertAction(title: "cancel", style: .cancel){ (action) in
            }
            
            let ac1 = UIAlertController(title: "Insufficient Tokens", message: "You do not have enough tokens to ask this question. Please buy more if you would like to ask this question.", preferredStyle: .alert)
            ac1.addAction(cancel)
            self.present(ac1, animated: true)
            return
        }
        if maxTokens > 4000 {
                maxTokens = 4000
        }
        
        let data : [String: Any] = [
            "message" : str, "max_tokens":maxTokens]
        let indicator = Indicator()
        indicator.label.text = "can take up\n to a minute..."
        indicator.showIndicator()
        indicator.alert.title = "ChatGPT can take up to two minutes."
        let funcGetData = Functions.functions().httpsCallable("getDataGrammar")
        funcGetData.timeoutInterval = 300000
        
        funcGetData.call(data) { (result, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
                indicator.hideIndicator {
                    let cancel = UIAlertAction(title: "cancel", style: .cancel){ (action) in
                    }
                    
                    let ac1 = UIAlertController(title: "Error", message: "Your request could not be processed.  Please try again.", preferredStyle: .alert)
                    ac1.addAction(cancel)
                    self.present(ac1, animated: true)
                    return
                }
            }

            else {
                //print(result?.data)
                if let dict = result?.data as? [String:Any] {
                    print("inside dict")
                    print(dict["info"])
                    print(dict["max_tokens"])

                    dict["info"]
                    
                    guard let exists = dict["info"] as? [String:Any], let max_tokens = dict["max_tokens"] as? Int else{
                        print(dict)
                        print("failing here")

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
                    
                    let db = Firestore.firestore()
                    
                    let ref = db.collection("users").document(UserService.user.id)
                    ref.updateData(["tokensRemaining":UserService.user.tokensRemaining-max_tokens*15]) { error in
                        if let error = error {
                            indicator.hideIndicator {
                                let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                                }
                                
                                let ac1 = UIAlertController(title: "Error", message: "Your request could not be processed.  Please try again.", preferredStyle: .alert)
                                ac1.addAction(cancel)
                                self.present(ac1, animated: true)
                            }

                        }
                        else {
                            print("success")
                        }
                    }
                    var prefixIndex = 10
                    if content.count > 35 {
                        prefixIndex = 35
                    }
                    else if content.count > 0{
                        prefixIndex = content.count-1
                    }
                    
                    let index = content.index(str.startIndex, offsetBy: prefixIndex)
                    
                    let prefix = content.prefix(upTo: index)
                        print("did i make it to here")
                        self.createTextView(content: content)
                    DocumentService.putDocument(subject: "English", field: "Grammar", text: content, question: str, docType: "txt",questionType: "Fix Grammar", questionTopic: "\(String(prefix))...", indicator: indicator)
                }
            }
        }
    }
    
    func createTextView(content:String){
        print("do i make the text view")
        textView.font = .systemFont(ofSize: 16)
        textView.text = content
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
            let viewcontroller = segue.destination as! PayWallViewController
            viewcontroller.segueID = "unwindToFix"
        }
    }
    
    @IBAction func unwindToFix(segue: UIStoryboardSegue){
        print("do i enter main")
        let tokensFormatted = DocumentService.formatNumber(UserService.user.tokensRemaining)
         tokens.setTitle("Tokens: \(tokensFormatted)", for: .normal)
        
        }
    
    @IBAction func helpButtonOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toHelp", sender: self)
    }
    
}
