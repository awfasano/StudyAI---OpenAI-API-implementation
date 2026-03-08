//
//  PayWallViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/12/23.
//

import UIKit
import Purchases
import Firebase

class PayWallViewController: UIViewController {

    private let header = PayWallHeaderView()
    let color = UIColor.init(hue: 0.0333, saturation: 0, brightness: 0.3, alpha: 1.0)

    let buyButton : UIButton = {
        let button = UIButton()
        button.setTitle("Buy Tokens", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()

    let restorePurchases : UIButton = {
        let button = UIButton()
        button.setTitle("Restore Purchases", for: .normal)
        button.setTitleColor(.link, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()
    
    private let heroView = PayWallDescriptionView()
    
    private let termsView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 12)
        textView.textColor = .secondaryLabel
        textView.text = "This is a one time purchase of 250,000 tokens.  You can buy more if you run out.  These tokens allow for the creation of study material."
        return textView
    }()
    
    
    var segueID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(header)
        //setUpCloseButton()
        setUpButtons()
        // Do any additional setup after loading the view.
        //CTA button

        view.addSubview(buyButton)
        view.addSubview(restorePurchases)
        view.addSubview(termsView)
        view.addSubview(heroView)

        //Terms of Service
        //close button and title
        //Pricing and product info
        
    }
    
    private func setUpButtons() {
        buyButton.addTarget(self, action: #selector(didTapBuyTokens), for: .touchUpInside)
        restorePurchases.addTarget(self, action: #selector(didTapRestore), for: .touchUpInside)
    }
    

    
    @objc private func didTapBuyTokens() {
        //revenue cat
        IAPManager.shared.fetchPackages { package in
            guard let package = package else {
                return
            }
            IAPManager.shared.buyTokens(package: package) { success in
                if success {
                    let db = Firestore.firestore()
                    let ref = db.collection("users").document(UserService.user.id)

                    let indicator = Indicator()
                    indicator.showIndicator()
                    ref.updateData(["tokensRemaining":UserService.user.tokensRemaining+250000]) { [self] error in
                        if let error = error {

                            indicator.hideIndicator {
                                let cancel = UIAlertAction(title: "OK", style: .cancel){ (action) in
                                }
                                
                                let ac1 = UIAlertController(title: "Error", message: "Error updating your tokens. Please contact as awfasano@gmail.com, and we will fix this issue immediately.", preferredStyle: .alert)
                                ac1.addAction(cancel)
                                present(ac1, animated: true)
                            }
                        }
                        else {
                            indicator.hideIndicator {
                                self.performSegue(withIdentifier: segueID ?? "unwindToMain", sender: self)

                            }
                        }
                    }
                    

                }
                else {
                        let alert = UIAlertController(title: "Purchase Failed", message: "We were unable to complete the transaction.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title:"Dismiss",style: .cancel, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    @objc private func didTapRestore() {
        let indicator = Indicator()
        indicator.alert.title = "Restoring..."
        indicator.showIndicator()
        IAPManager.shared.restorePurchases { [weak self] success in
            indicator.hideIndicator {
                if success {
                    let alert = UIAlertController(title: "Restored", message: "Your purchases have been restored.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Nothing to Restore", message: "We could not find any previous purchases to restore.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        header.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/3.2)
        
        termsView.frame = CGRect(x: 10, y: view.height-120, width: view.width - 20, height: 100)
        
        //restorePurchases.frame = CGRect(x: 10, y: view.height - 100, width: view.width - 100, height: 100)
        
        //restorePurchases.frame = CGRect(x: 25, y: termsView.top - 70, width: view.width - 50, height: 50)
        restorePurchases.frame = CGRect(x: 25, y: termsView.top - 40, width: view.width - 50, height: 30)
        buyButton.frame = CGRect(x: 25, y: restorePurchases.top - 60, width: view.width - 50, height: 50)

        heroView.frame = CGRect(x: 0, y: header.bottom, width: view.width, height: buyButton.top - view.safeAreaInsets.top - header.height)
    }
    
    private func setUpCloseButton() {
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .close,
                                                             target: self,
                                                             action: #selector(didTapClose)
        )
    }
    
    @objc private func  didTapClose() {
        dismiss(animated: true)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
