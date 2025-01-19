//
//  DocumentViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/4/23.
//

import UIKit
import WebKit
import PDFKit
import RichTextView

class DocumentViewController: UIViewController, WKNavigationDelegate,UITextViewDelegate {
    @IBOutlet weak var stackViewHgt: NSLayoutConstraint!
    @IBOutlet weak var textStackView: UIStackView!
    
    var webView:WKWebView?
    var docInformation:docInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let docInfoNotNil = docInformation else {
            let alertController = UIAlertController(title: "Error", message: "Getting your information", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        switch docInfoNotNil.docType {
        case "html":
            createHTML(content:docInfoNotNil.text)
        case "Latex":
            createRichTextView(content:docInfoNotNil.text)
        case "txt":
            createTextField(content:docInfoNotNil.text)
        default:
            print("error")
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func downloadOnTap(_ sender: Any) {
        guard let docInfoNotNil = docInformation else {
            let alertController = UIAlertController(title: "Error", message: "Getting your information", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default) { UIAlertAction in
                self.navigationController?.popViewController(animated: true)
            }
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        convertToPdfFileAndShare(str: docInfoNotNil.text, type: docInfoNotNil.docType, docInfoNotNil: docInfoNotNil)
       }

    @objc func download(){

    }
    
    func createHTML(content:String) {
        webView = WKWebView()
        webView?.navigationDelegate = self
        webView?.loadHTMLString(content, baseURL: nil)
        self.textStackView.addArrangedSubview(webView ?? WKWebView())
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("in did finish???")

        
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
                self.stackViewHgt.constant =  heightCGFloat + 75
            }
        }
    }
    
    func createTextField(content:String){
        let textView = UITextView(frame: .zero, textContainer: nil)

        textView.font = .systemFont(ofSize: 18)
        textView.delegate = self
        textView.text = content

        textView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.textStackView.frame.height)
        
        self.adjustUITextViewHeight(arg: textView)
        self.stackViewHgt.constant =  textView.frame.height + 75
        self.setDoneOnKeyboard(textView: textView)
        self.textStackView.addArrangedSubview(textView)
    }
    
    func createRichTextView(content:String){
        webView = WKWebView()
        webView?.navigationDelegate = self

        
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
        <span style=\"font-family: helvetica; font-size: 28">\(content)</span>
        </body>
        </html>
"""
        webView?.loadHTMLString(str, baseURL: nil)
        self.textStackView.addArrangedSubview(webView ?? WKWebView())
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
    
    func adjustUITextViewHeightRich(arg : RichTextView) {
        
        arg.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func convertToPdfFileAndShare(str: String,type:String, docInfoNotNil: docInfo){
        
        switch docInfoNotNil.docType {
        case "html":
            
            exportPDFHTML()
            print("am i in markup")
            
        case "Latex":

            let str1 = """
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
            <span style=\"font-family: helvetica; font-size: 20">\(str)</span>
            </body>
            </html>
    """
            
            exportPDFHTML()
            
        case "txt":
            let fmt = UISimpleTextPrintFormatter(text: docInfoNotNil.text)
            exportPDFText(fmt: fmt)
        default:
            print("error")
        }
    }
    
    func exportPDFText(fmt: UISimpleTextPrintFormatter) {
        
        print(fmt.text)
        // 2. Assign print formatter to UIPrintPageRenderer
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 50, y: 50, width: 550, height: 750) // A4, 72 dpi
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage();
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("output").appendingPathExtension("pdf")
            else { fatalError("Destination URL not created") }
        
        pdfData.write(to: outputURL, atomically: true)
        print("open \(outputURL.path)")
        
        if FileManager.default.fileExists(atPath: outputURL.path){
            
            let url = URL(fileURLWithPath: outputURL.path)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView=self.view
            
            //If user on iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                }
            }
            present(activityViewController, animated: true, completion: nil)
        }
        else {
            print("document was not found")
        }
    }
    
    func exportPDFHTML() {
        // 2. Assign print formatter to UIPrintPageRenderer
        
        let render = UIPrintPageRenderer()
        guard let webViewNotNil = webView else {
            return
        }
        
        render.addPrintFormatter(webViewNotNil.viewPrintFormatter(), startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        let page = CGRect(x: 50, y: 50, width: 550, height: 750) // A4, 72 dpi
        render.setValue(page, forKey: "paperRect")
        render.setValue(page, forKey: "printableRect")
        
        // 4. Create PDF context and draw
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 0..<render.numberOfPages {
            UIGraphicsBeginPDFPage();
            render.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        guard let outputURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(docInformation?.field ?? "")\(docInformation?.dateString ?? "output")").appendingPathExtension("pdf")
            else { fatalError("Destination URL not created") }
        
        pdfData.write(to: outputURL, atomically: true)
        print("open \(outputURL.path)")
        
        if FileManager.default.fileExists(atPath: outputURL.path){
            
            let url = URL(fileURLWithPath: outputURL.path)
            let activityViewController: UIActivityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView=self.view
            
            //If user on iPad
            if UIDevice.current.userInterfaceIdiom == .pad {
                if activityViewController.responds(to: #selector(getter: UIViewController.popoverPresentationController)) {
                }
            }
            present(activityViewController, animated: true, completion: nil)
        }
        else {
            print("document was not found")
        }
    }
}
