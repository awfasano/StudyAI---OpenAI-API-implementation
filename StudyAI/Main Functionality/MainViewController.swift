//
//  MainViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/15/23.
//

import UIKit
import WebKit
import Firebase
import RichTextView

class MainViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, reloadDelegate, UICollectionViewDelegate,UICollectionViewDataSource, WKNavigationDelegate,reloadUserDelegate {
    func reload() {
        let tokensFormatted = DocumentService.formatNumber(UserService.user.tokensRemaining)
         tokensButton.setTitle("Tokens: \(tokensFormatted)", for: .normal)
    }
    
    func reload(success: Bool) {
        if !success {
            let alertController = UIAlertController(title: "Error", message: "Unable to save your information to your Past Questions.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            print("do i hide here??")
        }
    }    
    @IBOutlet weak var scrollView: UIScrollView!
    var activeTextView: UITextView?
    var activeTextField: UITextField?

    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var tokensButton: UIButton!
    
    @IBOutlet weak var bottomCharRemainingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topCharRemainingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textStackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfCharacters: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var stackViewHgt: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var toggleGPTType: UIBarButtonItem!
    var switchCase = ""
    @IBOutlet weak var textStackView: UIStackView!
    var gptType = "gpt-3.5-turbo"
    var activityView: UIActivityIndicatorView?

    let indicatorInitial = Indicator()

    var tokens = UserService.user.tokensRemaining

    
    @IBOutlet weak var helpButton: UIButton!
    
    var systemString = ""
    
    var subject:String?
    var uiColor:UIColor?
    var field:String?
    var canSubmit = false
    var typeOfQuestion:[String]?
    var questionTypes:[String:[String]]? = [:]
    var questionTypesForDatabse:String?
    var useDictionary:[String:[String]] = [:]
    var keys:[String] = []
    var question = ""

    let flashcardString = "create flashcards in Javascript, HTML, and CSS that flip on click. Do not include any text before <!DOCTYPE html> or after the </html>. Width 500px and height of 500px with <br> between cards. The cards should have a vocab word on one side and a definition on the other."
    
    let mcString = """
    Write mutliple choice questions in Javascript and HTML
    where the correct answers are shown after the users presses a submit
    button.  Do not include an text before the <!DOCTYPE html> tag or
    after the </html> tag.  Each questions should have 4 possible
    answers.
    """
    
    let mathDitionary:[String:[String]] = ["5 Dynamic Multiple Choice Question":["Write five multiple choice questions about "],"10 Multiple Choice Question":["Create ten multiple choice questions that shows answers at the very bottom using MathJax to write the content"],"5 Dynamic Flashcards":["Write five flashcards about "],"Multiple Practice Problems with Solutions":["Write 5 practice problem with solutions on "," using MathJax notation to write the content"],"Step-by-Step Guide":["Create a step-by-step guide with a linebreak between steps explaining "," using MathJax notation to write the content."],"Detailed Solution":["Write a detailed step by step solution with a line break between steps on ", " using MathJax notation to write the content."],"Explanation of Concept":["Write a  detailed explanation of the conceptual understanding of ", " using MathJax notation to write the content."]]
    
    let mathKeys = ["5 Dynamic Multiple Choice Question", "5 Dynamic Flashcards", "Multiple Practice Problems with Solutions", "Multiple Practice Problems with Solutions", "Step-by-Step Guide", "Detailed Solution"]
    
    let scienceDitionary:[String:[String]] = ["20 Word Vocab List":["Write a 20 word vocab list with definitions beneath the work on "],"5 Dynamic Multiple Choice Question":["Write five multiple choice questions about "],"10 Multiple Choice Question":["Create ten multiple choice questions that shows answers at the very bottom"],"5 Dynamic Flashcards":["Write five flashcards about "], "Step-by-Step Guide":["Create a step-by-step guide with a linebreak between steps explaining "],"Detailed Solution":["Write a detailed step by step solution with a line break between steps on "],"Explanation of Concept":["Write a  detailed explanation of the conceptual understanding of "]]
    
    let scienceKeys = ["20 Word Vocab List", "5 Dynamic Flashcards", "Step-by-Step Guide", "Detailed Solution", "Step-by-Step Guide", "Detailed Solution", "Explanation of Concept"]
    
    
    let historyDitionary:[String:[String]] = ["20 Word Vocab List":["Write a 20 word vocab list with definitions on "],"5 Dynamic Multiple Choice Question":["Write five multiple choice questions about "],"5 Dynamic Flashcards":["Write five flashcards about "],"10 Multiple Choice Question":["Create ten multiple choice questions that shows answers at the very bottom"], "Example Essay Topics":["Write three comprehensive essay topics on "],"Free Response Questions with Example Essay":["Write a detailed step by step solution with a line break between steps on "],"Explanation of Concept":["Write a  detailed explanation of "], "Short Essays Examples":["Write two example short free response questions with solutions on "]]
    
    let historyKeys = ["20 Word Vocab List", "5 Dynamic Multiple Choice Question", "5 Dynamic Flashcards", "Example Essay Topics", "Example Essay Topics", "Free Response Questions with Example Essay", "Explanation of Concept", "Short Essays Examples"]
    
    let socialScienceDitionary:[String:[String]] = ["20 Word Vocab List":["Write a 20 word vocab list with definitions on "],"5 Dynamic Multiple Choice Question":["W`rite five questions about"],"5 Dynamic Flashcards":["Write five flashcards about "],"10 Multiple Choice Question":["Create ten multiple choice questions that shows answers at the very bottom"], "Example Essay Topics":["Write three comprehensive essay topics on "],"Free Response Questions with Example Essay":["Write a detailed step by step solution on "],"Explanation of Concept":["Write a  detailed explanation of "], "Short Essays Examples":["Write two example short free response questions with solutions on "]]
    
    let socialScienceKeys = ["20 Word Vocab List", "5 Dynamic Multiple Choice Question", "5 Dynamic Flashcards", "Example Essay Topics", "Short Essays Examples"]
    
    let englishDitionary:[String:[String]] = ["20 Word Vocab List":["Write a 20 word vocab list with definitions "],"5 Dynamic Multiple Choice Question":["Write five multiple choice questions about "],"5 Flashcards":["Write five flashcards about ","written using only HTML and JavaScript designed to fit a mobile device."], "Example Essay Topics":["Write three comprehensive essay topics on "],"Free Response Questions with Example Essay":["Write an example free response question on the example of ", ", and a comprehensive essay that answers all parts of this essay."],"Explanation of Concept":["Write a  detailed explanation of "],"10 Multiple Choice Question":["Create ten multiple choice questions that shows answers at the very bottom"], "Short Essays Examples":["Write two short example free response questions with answers on "], "Outline an Essay":["Create a Harvard style outline on the topic of "," that includes an introduction with a thesis, outline of multiple body paragraphs with topic sentences, warrants, and evidence.  Additionally, a short outline of the conclusion that ties all the points together."]]
    
    let englishKeys = ["20 Word Vocab List", "5 Dynamic Multiple Choice Question", "5 Dynamic Flashcards", "Example Essay Topics", "Short Essays Examples"]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if subject == nil || field == nil || uiColor == nil {
            let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                self.navigationController?.popViewController(animated: true)
            }
            
            let ac1 = UIAlertController(title: "Error", message: "There was an error getting your data..", preferredStyle: .alert)
            ac1.addAction(cancel)
            self.present(ac1, animated: true)
            return
        }
        
        if subject == "Math" || field == "Physics"{
            useDictionary = mathDitionary
        }
        
        else if subject == "Science" {
            useDictionary = scienceDitionary
            
        }
        else if subject == "History"{
            useDictionary = historyDitionary
            
        }
        else if subject == "Social Sciences"{
            useDictionary = socialScienceDitionary
        }
        else if subject == "English"{
            useDictionary = englishDitionary
        }
        else {
            let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                self.navigationController?.popViewController(animated: true)
            }
            
            let ac1 = UIAlertController(title: "Error", message: "There was an error getting your data..", preferredStyle: .alert)
            ac1.addAction(cancel)
            self.present(ac1, animated: true)
            return
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        UserService.delegate = self
        self.setupInterface()

        if !UserService.user.isVerifiable && !UserService.user.receivedTokens {
            showActivityIndicator()
            let auth = Auth.auth()
            auth.currentUser?.reload { err in
                if let err = err {
                        self.setupInterface()
                }
                else {
                    if auth.currentUser?.isEmailVerified ?? false {
                            let db = Firestore.firestore()
                            let ref = db.collection("users").document(UserService.user.id)
                            ref.updateData(["isVerifiable":true, "tokensRemaining":UserService.user.tokensRemaining+50000,"receivedTokens":true]) { err in
                                if let err = err {
                                    self.hideActivityIndicator()
                                }
                                else {
                                        print("third last else")
                                    self.hideActivityIndicator()

                                }
                            }
                        }
                    else {
                        self.hideActivityIndicator()

                        print("second last else")
                    }
                }
            }
        }
            else {
                    print("last else")
                    self.setupInterface()
            }
    }
    
    func createHTML(content:String) {
        print(content)
        
        let webView1 = WKWebView()
        webView1.navigationDelegate = self
        webView1.loadHTMLString(content, baseURL: nil)
        self.textStackView.addArrangedSubview(webView1)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("in did finish???")

        
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                
                webView.evaluateJavaScript("document.documentElement.scrollHeight") { (height, error) in
                    if let err = error {
                        self.stackViewHgt.constant =  350
                    }
                    else {
                        guard let heightCGFloat = height as? CGFloat
                        else {
                            self.stackViewHgt.constant =  350
                            return
                        }
                        if self.question.contains("MathJax") {
                            self.stackViewHgt.constant =  heightCGFloat/2.5

                        }
                        else {
                            self.stackViewHgt.constant =  heightCGFloat

                            }
                        }
                    }
                }
            })
        }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell =  self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QuestionTypesCollectionViewCell

        let dicKeys = Array(useDictionary.keys)
        keys = dicKeys
        cell.label.text = dicKeys[indexPath.row]
        cell.label.textColor = uiColor

        //cell.layer.cornerRadius = (cell.frame.height)/12
        cell.layer.masksToBounds = true
        
        cell.layer.borderColor = uiColor?.cgColor
        cell.layer.borderWidth = 2.5
        
        let view = UIView()
        //view.layer.cornerRadius = (cell.frame.height)/12
        
        switch subject {
    
        case "Math":

            view.backgroundColor = uiColor?.adjustBrightness(by: 65).withAlphaComponent(0.5)
            cell.selectedBackgroundView = view

        case "Science":
            view.backgroundColor = uiColor?.adjustBrightness(by: 50).withAlphaComponent(0.65)
            cell.selectedBackgroundView = view

        case "Foreign Languages":
                        
            view.backgroundColor  = uiColor?.adjustBrightness(by: 50).withAlphaComponent(0.5)
            cell.selectedBackgroundView = view

        case "Social Sciences":
                        
            view.backgroundColor = uiColor?.adjustBrightness(by: 50).withAlphaComponent(0.5)
            cell.selectedBackgroundView = view

        case "English":
            
            view.backgroundColor = uiColor?.adjustBrightness(by: 100).withAlphaComponent(0.4)
            cell.selectedBackgroundView = view

        case "History":
            view.backgroundColor = uiColor?.adjustBrightness(by: 50).withAlphaComponent(0.5)
            cell.selectedBackgroundView = view
            
        default:
            print("error")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return useDictionary.keys.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        typeOfQuestion = useDictionary[keys[indexPath.row]]
        questionTypesForDatabse = keys[indexPath.row]
    }
    
    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 40
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func createTextField(content:String){
        let textView = UITextView(frame: .zero, textContainer: nil)

        textView.font = .systemFont(ofSize: 18)
        textView.delegate = self
        textView.text = content

        textView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.textStackView.frame.height)
        
        self.adjustUITextViewHeight(arg: textView)
        self.stackViewHgt.constant =  textView.frame.height + 25
        self.setDoneOnKeyboard(textView: textView)
        
        self.textStackView.addArrangedSubview(textView)
    }

    func makeCallToOpenAI(str:String, system:String){
        print(system)
        let tokenQuestions = Int(Double(str.count)/4.0)
        var maxTokens = UserService.user.tokensRemaining-tokenQuestions
        
        if maxTokens < 200 {
            let cancel = UIAlertAction(title: "cancel", style: .cancel){ (action) in
            }
            
            let ac1 = UIAlertController(title: "Insufficient Tokens", message: "You do not have enough tokens to ask this question. Please buy more if you would like to ask this question.", preferredStyle: .alert)
            ac1.addAction(cancel)
            self.present(ac1, animated: true)
            return
        }
        if maxTokens > 4000 {
            if self.gptType == "gpt-3.5-turbo"{
                maxTokens = 4000
            }
            else {
                if maxTokens > 8000 {
                    maxTokens = 8000
                }
            }
        }
        
        let data : [String: Any] = [
            "message" : str, "model":gptType, "max_tokens":maxTokens, "system":system]
        print(system)
        
        let indicator = Indicator()
        indicator.alert.title = "Can take up to 90 minutes for dynamic content."
        indicator.showIndicator()
        
        let funcGetData = Functions.functions().httpsCallable("getData")
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
                }

                return
            }
            
            else {
                
                //print(result?.data)
                
                if let dict = result?.data as? [String:Any] {
                    //print(dict)
                    
                    print("max tokens")
                    print(dict)
                    
                    
                    guard let exists = dict["info"] as? [String:Any], let max_tokens = dict["max_tokens"] as? Int else{
                        return
                    }
                    
                    guard let content = exists["content"] as? String else {
                        let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                        }
                        
                        let ac1 = UIAlertController(title: "Error", message: "Your request could not be processed.  Please try again.", preferredStyle: .alert)
                        ac1.addAction(cancel)
                        self.present(ac1, animated: true)
                        
                        return
                    }
                    
                    let db = Firestore.firestore()
                    
                    let ref = db.collection("users").document(UserService.user.id)
                    var multiplier:Int{
                        if self.gptType == "gpt-3.5-turbo"{
                            return 1
                        }
                        else {
                            return 15
                        }
                    }
                    
                    ref.updateData(["tokensRemaining":UserService.user.tokensRemaining-max_tokens*multiplier]) { error in
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
                            
                    if self.textStackView.subviews.count != 0 {
                        self.textStackView.subviews.forEach({ $0.removeFromSuperview() })
                        self.stackViewHgt.constant = 0
                        // this gets things done
                    }
                    
                    if str.contains("Write five multiple choice questions about") || str.contains("flashcards"){
                        print("do i got into HTML")
                        self.createHTML(content:content)
                        DocumentService.putDocument(subject: self.subject!, field: self.field!, text: content, question: str, docType: "html",questionType: self.questionTypesForDatabse ?? "", questionTopic: self.textField.text ?? "", indicator: indicator)
                    }
                    else if str.contains("MathJax") {
                        self.createRichTextView(content:content)
                        DocumentService.putDocument(subject: self.subject!, field: self.field!, text: content, question: str, docType: "Latex",questionType: self.questionTypesForDatabse ?? "", questionTopic: self.textField.text ?? "", indicator: indicator)
                        
                    }
                    else {
                        self.createTextField(content: content)
                        DocumentService.putDocument(subject: self.subject!, field: self.field!, text: content, question: str, docType: "txt",questionType: self.questionTypesForDatabse ?? "", questionTopic: self.textField.text ?? "", indicator: indicator)
                        
                    }
                }
            }
        }
    }
            
    
    func createRichTextView(content:String){
        let webView1 = WKWebView()
        webView1.navigationDelegate = self

        let str = """
        <html>
        <head>
        <title>MathJax TeX Test Page</title>
        <script>
        MathJax = {
          tex: {
            inlineMath: [['$', '$'], ['\\(', '\\)']]
          },
          svg: {
            fontCache: 'global'
          }
        };
        </script>
        <script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
        <script type="text/javascript" id="MathJax-script" async
          src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-chtml.js">
        </script>
        </head>
        <body>
        <span style=\"font-family: helvetica; font-size: 38">\(content)</span>
        </body>
        </html>
"""
        webView1.loadHTMLString(str, baseURL: nil)
        self.textStackView.addArrangedSubview(webView1)
        
    }
    
    func setDoneOnKeyboard(textView:UITextView) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        textView.inputAccessoryView = keyboardToolbar
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("While entering the characters this method gets called")
        return true;
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let numberremaining = 50 - (textField.text?.count ?? 0)
        
        if textField.text == nil || textField.text == "" {
            canSubmit = false
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .black

        }
        else if textField.text!.count > 50 {
            canSubmit = false
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .red
        }
        else {
            canSubmit = true
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .black

        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        let numberremaining = 50 - (textField.text?.count ?? 0)

        if textField.text == nil {
            canSubmit = false
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .black

        }
        else if textField.text!.count > 50 {
            canSubmit = false
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .red
        }
        else {
            canSubmit = true
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .black
        }
    }
    
    @IBAction func toggleGPTLevel(_ sender: Any) {
        
        if gptType == "gpt-3.5-turbo"{
            gptType = "gpt-4"

            toggleGPTType.title = "GPT4"

        }
        else {
            gptType = "gpt-3.5-turbo"
            toggleGPTType.title = "ChatGPT3.5"
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
    
    
    @IBAction func buttonOnTap(_ sender: Any) {
        print(canSubmit)
        print(canSubmit)

        if typeOfQuestion != nil {
            if canSubmit {
                var str = ""
                
                switch typeOfQuestion?.count{
                case 0:
                    str = "On the topic of \(field!): \(textField.text ?? "")"
                    question = str
                    systemString = " "
                    
                    if subject!.elementsEqual("Math") || field!.elementsEqual("Physics"){
                                                
                        systemString = " for inline formulas you use either a dollar sign $. To end the inline math, you have another dollar sign. Don't write the word MathJax in the solution"
                        
                        print("am I in system string flashcard")
                    }
                    
                case 1:
                    
                    if typeOfQuestion![0].contains("Write five multiple choice questions about "){
                        systemString = mcString
                        print("am I in system string multiple choice")
                    }
                    else if typeOfQuestion![0].contains("Write five flashcards about "){
                        systemString = flashcardString
                        print("am I in system string flashcard")
                    }
                    else if subject!.elementsEqual("Math") || field!.elementsEqual("Physics"){
                                                
                        systemString = " for inline formulas you use either a dollar sign $. To end the inline math, you have another dollar sign. Don't write the word MathJax in the solution"

                        print("am I in system string flashcard")
                    }
                    
                    else {
                        systemString = " "
                    }
                    str = "On the topic of \(field!): \(typeOfQuestion![0]) \(textField.text ?? "")"
                    question = str

                case 2:
                    str = "On the topic of \(field!): \(typeOfQuestion![0]) \(textField.text ?? "") \(typeOfQuestion![1])"
                    question = str
                    systemString = " "
                    if subject!.elementsEqual("Math") || field!.elementsEqual("Physics"){
                                                
                        systemString = " for inline formulas you use either a dollar sign $. To end the inline math, you have another dollar sign. Don't write the word MathJax in the solution"

                        print("am I in system string flashcard")
                    }

                default:
                    str = "On the topic of \(field): \(textField.text ?? "")"
                    question = str
                    systemString = " "
                }
                
                makeCallToOpenAI(str: str, system: systemString)
                print("am I in system string flashcard")

        }
            else {
                let cancel = UIAlertAction(title: "cancel", style: .cancel){ (action) in
                }
                
                let ac1 = UIAlertController(title: "Error", message: "You cannot have over 50 Characters for your topic or 0.", preferredStyle: .alert)
                ac1.addAction(cancel)
                self.present(ac1, animated: true)
                return
            }
        }
        
        else {
            let cancel = UIAlertAction(title: "cancel", style: .cancel){ (action) in
            }
            
            let ac1 = UIAlertController(title: "Error", message: "Please select a type of question.", preferredStyle: .alert)
            ac1.addAction(cancel)
            self.present(ac1, animated: true)
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPaywallVC" {
            let viewcontroller = segue.destination as! PayWallViewController
            viewcontroller.segueID = "unwindToMain"
        }
    }

    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
       let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.greatestFiniteMagnitude))
       label.numberOfLines = 0
       label.lineBreakMode = NSLineBreakMode.byWordWrapping
       label.font = font
       label.text = text

       label.sizeToFit()
       return label.frame.height + 50
   }
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.isScrollEnabled = false
        arg.sizeToFit()
    }
    func adjustUITextViewHeightRich(arg : RichTextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
    }
    
    @IBAction func tokensOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toPaywallVC", sender: self)
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue){
        print("do i enter main")
        let tokensFormatted = DocumentService.formatNumber(UserService.user.tokensRemaining)
         tokensButton.setTitle("Tokens: \(tokensFormatted)", for: .normal)
        }
    
    func setupInterface() {
        var tokens = UserService.user.tokensRemaining {
            didSet {
               let tokensFormatted = DocumentService.formatNumber(tokens)
                tokensButton.setTitle("Tokens: \(tokensFormatted)", for: .normal)
            }
        }
                
        Utilities.styleFillButton2(button, color: uiColor ?? .blue)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
        
        let tokensFormatted = DocumentService.formatNumber(tokens)
         tokensButton.setTitle("Tokens: \(tokensFormatted)", for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        let image = UIImage(named: "transparentIcon.png")
        chatButton.backgroundColor = .clear
        chatButton.setImage(image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
        
        chatButton.imageView?.contentMode = .scaleAspectFit
        //addViewsHeight.constant = 800
        Utilities.styleTextField(textField, color: uiColor)
    }
    
    @IBAction func helpButtonOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toHelp", sender: self)
    }
    
    func showActivityIndicator() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }

    func hideActivityIndicator(){
        if (activityView != nil){
            activityView?.stopAnimating()
        }
    }
    
    @IBAction func chatButtonOnPress(_ sender: Any) {
        performSegue(withIdentifier: "toChat", sender: self)
    }
    
    
}
