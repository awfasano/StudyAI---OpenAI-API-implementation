//
//  MainViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/15/23.
//

import UIKit
import WebKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

class MainViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, reloadDelegate, UICollectionViewDelegate,UICollectionViewDataSource, WKNavigationDelegate,reloadUserDelegate {
    private let heroTag = 9_201
    private let resultsCardTag = 9_202

    func reload() {
        refreshAccessButton()
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
    var gptType = "gpt-4o-mini"
    var activityView: UIActivityIndicatorView?

    let indicatorInitial = Indicator()

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
    
    let mathDitionary:[String:[String]] = [
        "5 Multiple Choice":["Write five multiple choice questions about "],
        "10 Multiple Choice":["Create ten multiple choice questions that shows answers at the very bottom using MathJax to write the content"],
        "5 Flashcards":["Write five flashcards about "],
        "Practice Problems":["Write 5 practice problem with solutions on "," using MathJax notation to write the content"],
        "Step-by-Step Guide":["Create a step-by-step guide with a linebreak between steps explaining "," using MathJax notation to write the content."],
        "Detailed Solution":["Write a detailed step by step solution with a line break between steps on ", " using MathJax notation to write the content."],
        "Explain Concept":["Write a detailed explanation of the conceptual understanding of ", " using MathJax notation to write the content."]
    ]

    let mathKeys = ["5 Multiple Choice", "5 Flashcards", "Practice Problems", "Step-by-Step Guide", "Detailed Solution", "Explain Concept"]

    let scienceDitionary:[String:[String]] = [
        "Vocab List (20 Words)":["Write a 20 word vocab list with definitions beneath the word on "],
        "5 Multiple Choice":["Write five multiple choice questions about "],
        "10 Multiple Choice":["Create ten multiple choice questions that shows answers at the very bottom"],
        "5 Flashcards":["Write five flashcards about "],
        "Step-by-Step Guide":["Create a step-by-step guide with a linebreak between steps explaining "],
        "Detailed Solution":["Write a detailed step by step solution with a line break between steps on "],
        "Explain Concept":["Write a detailed explanation of the conceptual understanding of "]
    ]

    let scienceKeys = ["Vocab List (20 Words)", "5 Multiple Choice", "5 Flashcards", "Step-by-Step Guide", "Detailed Solution", "Explain Concept"]

    let historyDitionary:[String:[String]] = [
        "Vocab List (20 Words)":["Write a 20 word vocab list with definitions on "],
        "5 Multiple Choice":["Write five multiple choice questions about "],
        "5 Flashcards":["Write five flashcards about "],
        "10 Multiple Choice":["Create ten multiple choice questions that shows answers at the very bottom"],
        "Essay Topics":["Write three comprehensive essay topics on "],
        "Free Response + Essay":["Write a detailed step by step solution with a line break between steps on "],
        "Explain Concept":["Write a detailed explanation of "],
        "Short Essay Examples":["Write two example short free response questions with solutions on "]
    ]

    let historyKeys = ["Vocab List (20 Words)", "5 Multiple Choice", "5 Flashcards", "Essay Topics", "Free Response + Essay", "Explain Concept", "Short Essay Examples"]

    let socialScienceDitionary:[String:[String]] = [
        "Vocab List (20 Words)":["Write a 20 word vocab list with definitions on "],
        "5 Multiple Choice":["Write five multiple choice questions about "],
        "5 Flashcards":["Write five flashcards about "],
        "10 Multiple Choice":["Create ten multiple choice questions that shows answers at the very bottom"],
        "Essay Topics":["Write three comprehensive essay topics on "],
        "Free Response + Essay":["Write a detailed step by step solution on "],
        "Explain Concept":["Write a detailed explanation of "],
        "Short Essay Examples":["Write two example short free response questions with solutions on "]
    ]

    let socialScienceKeys = ["Vocab List (20 Words)", "5 Multiple Choice", "5 Flashcards", "Essay Topics", "Short Essay Examples"]

    let englishDitionary:[String:[String]] = [
        "Vocab List (20 Words)":["Write a 20 word vocab list with definitions "],
        "5 Multiple Choice":["Write five multiple choice questions about "],
        "5 Flashcards":["Write five flashcards about ","written using only HTML and JavaScript designed to fit a mobile device."],
        "Essay Topics":["Write three comprehensive essay topics on "],
        "Free Response + Essay":["Write an example free response question on the example of ", ", and a comprehensive essay that answers all parts of this essay."],
        "Explain Concept":["Write a detailed explanation of "],
        "10 Multiple Choice":["Create ten multiple choice questions that shows answers at the very bottom"],
        "Short Essay Examples":["Write two short example free response questions with answers on "],
        "Essay Outline":["Create a Harvard style outline on the topic of "," that includes an introduction with a thesis, outline of multiple body paragraphs with topic sentences, warrants, and evidence. Additionally, a short outline of the conclusion that ties all the points together."]
    ]

    let englishKeys = ["Vocab List (20 Words)", "5 Multiple Choice", "5 Flashcards", "Essay Topics", "Short Essay Examples"]

    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        view.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        
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
        refreshAccessButton()
    }
    
    func createHTML(content:String) {
        
        let webView1 = WKWebView()
        webView1.navigationDelegate = self
        webView1.loadHTMLString(content, baseURL: nil)
        self.textStackView.addArrangedSubview(webView1)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        
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
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? QuestionTypesCollectionViewCell else {
            return UICollectionViewCell()
        }

        let dicKeys = Array(useDictionary.keys)
        keys = dicKeys
        cell.label.text = dicKeys[indexPath.row]
        cell.label.textColor = uiColor
        cell.label.font = .systemFont(ofSize: 16, weight: .heavy)
        cell.info.text = field
        cell.info.textColor = AIcademyTheme.ink.withAlphaComponent(0.62)
        cell.info.font = .systemFont(ofSize: 12, weight: .medium)

        //cell.layer.cornerRadius = (cell.frame.height)/12
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 24
        cell.backgroundColor = AIcademyTheme.surface
        
        cell.layer.borderColor = uiColor?.cgColor
        cell.layer.borderWidth = 2.5
        cell.layer.shadowColor = AIcademyTheme.ink.cgColor
        cell.layer.shadowOpacity = 0.08
        cell.layer.shadowRadius = 12
        cell.layer.shadowOffset = CGSize(width: 0, height: 8)
        
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
            break
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
        guard let keyboardValue = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return }
        var keyboardFrame: CGRect = keyboardValue.cgRectValue
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
        Utilities.styleTextView(textView, color: uiColor)

        textView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.textStackView.frame.height)
        
        self.adjustUITextViewHeight(arg: textView)
        self.stackViewHgt.constant =  textView.frame.height + 25
        self.setDoneOnKeyboard(textView: textView)
        
        self.textStackView.addArrangedSubview(textView)
    }

    func generationBudget() -> Int {
        gptType == "gpt-4o-mini" ? 4000 : 8000
    }

    func makeCallToOpenAI(str:String, system:String){
        StudyAccessManager.shared.accessSnapshot(for: .generator) { snapshot in
            DispatchQueue.main.async {
                guard snapshot.canUseFeature else {
                    self.presentUsageLimitAlert(
                        title: "Free Plan Limit Reached",
                        message: "Free users get \(StudyAccessFeature.generator.dailyFreeLimit) study generations per day. Upgrade to Premium for fuller access."
                    )
                    return
                }

                let maxTokens = self.generationBudget()
                let modelName = (self.gptType == "gpt-4o-mini") ? "GPT-4o mini" : "GPT-4o"

                let confirmAlert = UIAlertController(
                    title: "Confirm Generation",
                    message: snapshot.confirmMessage(for: modelName),
                    preferredStyle: .alert
                )
                confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                confirmAlert.addAction(UIAlertAction(title: "Generate", style: .default) { _ in
                    self.executeOpenAICall(str: str, system: system, maxTokens: maxTokens)
                })
                self.present(confirmAlert, animated: true)
            }
        }
    }

    func executeOpenAICall(str: String, system: String, maxTokens: Int) {
        let data : [String: Any] = [
            "message" : str, "model":gptType, "max_tokens":maxTokens, "system":system]

        let indicator = Indicator()
        indicator.alert.title = "Generating your content..."
        indicator.showIndicator()
        
        let funcGetData = Functions.functions().httpsCallable("getData")
        funcGetData.timeoutInterval = 300000
                
        funcGetData.call(data) { (result, error) in
            if let error = error {
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
                    
                    if self.textStackView.subviews.count != 0 {
                        self.textStackView.subviews.forEach({ $0.removeFromSuperview() })
                        self.stackViewHgt.constant = 0
                        // this gets things done
                    }
                    
                    if str.contains("Write five multiple choice questions about") || str.contains("flashcards"){
                        self.createHTML(content:content)
                        DocumentService.putDocument(subject: self.subject ?? "", field: self.field ?? "", text: content, question: str, docType: "html",questionType: self.questionTypesForDatabse ?? "", questionTopic: self.textField.text ?? "", indicator: indicator)
                    }
                    else if str.contains("MathJax") {
                        self.createRichTextView(content:content)
                        DocumentService.putDocument(subject: self.subject ?? "", field: self.field ?? "", text: content, question: str, docType: "Latex",questionType: self.questionTypesForDatabse ?? "", questionTopic: self.textField.text ?? "", indicator: indicator)
                        
                    }
                    else {
                        self.createTextField(content: content)
                        DocumentService.putDocument(subject: self.subject ?? "", field: self.field ?? "", text: content, question: str, docType: "txt",questionType: self.questionTypesForDatabse ?? "", questionTopic: self.textField.text ?? "", indicator: indicator)
                        
                    }
                    StudyAccessManager.shared.recordSuccessfulUse(for: .generator) {
                        DispatchQueue.main.async {
                            self.refreshAccessButton()
                        }
                    }
                }
            }
        }
    }
            
    
    func createRichTextView(content:String){
        let webView1 = WKWebView()
        webView1.navigationDelegate = self
        webView1.layer.cornerRadius = 24
        webView1.layer.borderWidth = 2
        webView1.layer.borderColor = (uiColor ?? AIcademyTheme.border).cgColor
        webView1.clipsToBounds = true

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
        return true;
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let numberremaining = 50 - (textField.text?.count ?? 0)
        
        if textField.text == nil || textField.text == "" {
            canSubmit = false
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .label

        }
        else if textField.text!.count > 50 {
            canSubmit = false
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .red
        }
        else {
            canSubmit = true
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .label

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
            numberOfCharacters.textColor = .label

        }
        else if textField.text!.count > 50 {
            canSubmit = false
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .red
        }
        else {
            canSubmit = true
            numberOfCharacters.text = "Characters Remaining: \(numberremaining)"
            numberOfCharacters.textColor = .label
        }
    }
    
    @IBAction func toggleGPTLevel(_ sender: Any) {
        
        if gptType == "gpt-4o-mini" {
            gptType = "gpt-4o"
            toggleGPTType.title = "GPT-4o"
        } else {
            gptType = "gpt-4o-mini"
            toggleGPTType.title = "GPT-4o mini"
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        activeTextView = nil
    }
    
    
    @IBAction func buttonOnTap(_ sender: Any) {

        if typeOfQuestion != nil {
            if canSubmit {
                var str = ""
                
                let currentField = field ?? ""
                let currentSubject = subject ?? ""
                let questions = typeOfQuestion ?? []

                switch questions.count {
                case 0:
                    str = "On the topic of \(currentField): \(textField.text ?? "")"
                    question = str
                    systemString = " "

                    if currentSubject == "Math" || currentField == "Physics" {
                        systemString = " for inline formulas you use either a dollar sign $. To end the inline math, you have another dollar sign. Don't write the word MathJax in the solution"
                    }

                case 1:
                    if questions[0].contains("Write five multiple choice questions about ") {
                        systemString = mcString
                    } else if questions[0].contains("Write five flashcards about ") {
                        systemString = flashcardString
                    } else if currentSubject == "Math" || currentField == "Physics" {
                        systemString = " for inline formulas you use either a dollar sign $. To end the inline math, you have another dollar sign. Don't write the word MathJax in the solution"
                    } else {
                        systemString = " "
                    }
                    str = "On the topic of \(currentField): \(questions[0]) \(textField.text ?? "")"
                    question = str

                case 2:
                    str = "On the topic of \(currentField): \(questions[0]) \(textField.text ?? "") \(questions[1])"
                    question = str
                    systemString = " "
                    if currentSubject == "Math" || currentField == "Physics" {
                        systemString = " for inline formulas you use either a dollar sign $. To end the inline math, you have another dollar sign. Don't write the word MathJax in the solution"
                    }

                default:
                    str = "On the topic of \(currentField): \(textField.text ?? "")"
                    question = str
                    systemString = " "
                }
                
                makeCallToOpenAI(str: str, system: systemString)

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
            guard let viewcontroller = segue.destination as? PayWallViewController else { return }
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
    @IBAction func tokensOnTap(_ sender: Any) {
        performSegue(withIdentifier: "toPaywallVC", sender: self)
    }
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue){
        refreshAccessButton()
        }
    
    func setupInterface() {
        Utilities.styleFillButton2(button, color: uiColor ?? .blue)
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = self
        AIcademyTheme.styleSurface(stackView, tint: uiColor)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 22, left: 18, bottom: 26, right: 18)
        collectionView.backgroundColor = .clear
        collectionView.layer.cornerRadius = 22

        Utilities.styleHollowButton(tokensButton)
        Utilities.styleHollowButton(chatButton)
        Utilities.styleHollowButton(helpButton)
        tokensButton.titleLabel?.numberOfLines = 2
        tokensButton.titleLabel?.textAlignment = .center
        chatButton.setTitle(" Carlisle", for: .normal)
        chatButton.setTitleColor(AIcademyTheme.ink, for: .normal)
        helpButton.setTitle(" Help", for: .normal)
        helpButton.setTitleColor(AIcademyTheme.ink, for: .normal)
        tokensButton.setTitleColor(AIcademyTheme.ink, for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
        let image = UIImage(named: "transparentIcon.png")
        chatButton.backgroundColor = .clear
        chatButton.setImage(image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), for: .normal)
        
        chatButton.imageView?.contentMode = .scaleAspectFit
        //addViewsHeight.constant = 800
        Utilities.styleTextField(textField, color: uiColor)
        numberOfCharacters.textColor = AIcademyTheme.ink.withAlphaComponent(0.7)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Enter a focused topic or concept",
            attributes: [.foregroundColor: AIcademyTheme.ink.withAlphaComponent(0.45)]
        )
        installHeroIfNeeded()
        installResultsCardIfNeeded()
        refreshAccessButton()
    }

    private func refreshAccessButton() {
        StudyAccessManager.shared.accessSnapshot(for: .generator) { snapshot in
            DispatchQueue.main.async {
                self.tokensButton.setTitle(snapshot.buttonTitle, for: .normal)
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

    private func installHeroIfNeeded() {
        guard stackView.arrangedSubviews.first(where: { $0.tag == heroTag }) == nil else { return }

        let heroCard = UIView()
        heroCard.tag = heroTag
        AIcademyTheme.styleSurface(heroCard, tint: uiColor)

        let heroImage = UIImageView(frame: .zero)
        Utilities.applyHeroImage(heroImage)
        heroImage.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.text = "\(field ?? subject ?? "Study") with Carlisle"
        AIcademyTheme.styleTitle(title, size: 28)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.numberOfLines = 0
        subtitle.text = "Pick a format, add a topic, and generate something you can actually study from."
        AIcademyTheme.styleSubtitle(subtitle, size: 15)

        let pill = UILabel()
        pill.translatesAutoresizingMaskIntoConstraints = false
        pill.text = " \(subject ?? "Study") • \(gptType == "gpt-4o-mini" ? "Fast mode" : "Deep mode") "
        pill.font = .systemFont(ofSize: 12, weight: .bold)
        pill.textColor = AIcademyTheme.ink
        pill.backgroundColor = (uiColor ?? AIcademyTheme.yellow).withAlphaComponent(0.2)
        pill.layer.cornerRadius = 14
        pill.clipsToBounds = true

        let textStack = UIStackView(arrangedSubviews: [pill, title, subtitle])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 10
        textStack.alignment = .leading

        heroCard.addSubview(heroImage)
        heroCard.addSubview(textStack)

        NSLayoutConstraint.activate([
            heroImage.leadingAnchor.constraint(equalTo: heroCard.leadingAnchor, constant: 18),
            heroImage.topAnchor.constraint(equalTo: heroCard.topAnchor, constant: 18),
            heroImage.widthAnchor.constraint(equalToConstant: 88),
            heroImage.heightAnchor.constraint(equalToConstant: 88),

            textStack.leadingAnchor.constraint(equalTo: heroImage.trailingAnchor, constant: 16),
            textStack.trailingAnchor.constraint(equalTo: heroCard.trailingAnchor, constant: -18),
            textStack.centerYAnchor.constraint(equalTo: heroCard.centerYAnchor),

            heroCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 124)
        ])

        stackView.insertArrangedSubview(heroCard, at: 0)
    }

    private func installResultsCardIfNeeded() {
        guard textStackView.arrangedSubviews.first(where: { $0.tag == resultsCardTag }) == nil else { return }

        let header = UIView()
        header.tag = resultsCardTag
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = AIcademyTheme.surface.withAlphaComponent(0.95)
        header.layer.cornerRadius = 22
        header.layer.borderWidth = 2
        header.layer.borderColor = (uiColor ?? AIcademyTheme.border).cgColor

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Generated Study Sheet"
        AIcademyTheme.styleTitle(title, size: 22)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Your generated material will appear here once Carlisle finishes."
        subtitle.numberOfLines = 0
        AIcademyTheme.styleSubtitle(subtitle, size: 14)

        header.addSubview(title)
        header.addSubview(subtitle)
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -18),
            title.topAnchor.constraint(equalTo: header.topAnchor, constant: 16),
            subtitle.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 18),
            subtitle.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -18),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            subtitle.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: -16)
        ])

        textStackView.insertArrangedSubview(header, at: 0)
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
