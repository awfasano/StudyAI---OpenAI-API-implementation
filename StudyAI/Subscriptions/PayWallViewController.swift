//
//  PayWallViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/12/23.
//

import UIKit
import RevenueCat
import FirebaseFirestore

class PayWallViewController: UIViewController {

    private let header = PayWallHeaderView()
    private let headlineLabel = UILabel()
    private let monthlyButton = UIButton(type: .system)
    private let annualButton = UIButton(type: .system)
    private let packageStatusLabel = UILabel()
    private var monthlyPackage: Package?
    private var annualPackage: Package?
    private var selectedPackage: Package?

    let buyButton : UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        return button
    }()

    let restorePurchases : UIButton = {
        let button = UIButton()
        button.setTitle("Restore Purchases", for: .normal)
        return button
    }()
    
    private let heroView = PayWallDescriptionView()
    
    private let termsView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textAlignment = .center
        textView.font = .systemFont(ofSize: 12)
        textView.textColor = .secondaryLabel
        textView.text = "Choose a monthly or annual premium plan to unlock fuller study generation and more time with Carlisle."
        return textView
    }()
    
    
    var segueID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        view.addSubview(header)
        configureHeadline()
        setUpButtons()
        configurePackageButtons()

        view.addSubview(buyButton)
        view.addSubview(restorePurchases)
        view.addSubview(termsView)
        view.addSubview(heroView)
        view.addSubview(monthlyButton)
        view.addSubview(annualButton)
        view.addSubview(packageStatusLabel)
        Utilities.styleFillButton(buyButton)
        Utilities.styleLinkButton(restorePurchases)
        termsView.backgroundColor = .clear
        termsView.textColor = AIcademyTheme.ink.withAlphaComponent(0.7)
        termsView.text = "Premium gives you more room to generate study material, review with Carlisle, and keep momentum across the app."
        packageStatusLabel.textAlignment = .center
        packageStatusLabel.numberOfLines = 0
        AIcademyTheme.styleSubtitle(packageStatusLabel, size: 13)
        packageStatusLabel.text = "Loading plans..."
        loadPackages()
        
    }
    
    private func setUpButtons() {
        buyButton.addTarget(self, action: #selector(didTapBuyPremium), for: .touchUpInside)
        restorePurchases.addTarget(self, action: #selector(didTapRestore), for: .touchUpInside)
    }

    private func configureHeadline() {
        AIcademyTheme.styleTitle(headlineLabel, size: 30)
        headlineLabel.text = "Go Premium"
        headlineLabel.textAlignment = .center
        view.addSubview(headlineLabel)
    }

    private func configurePackageButtons() {
        [monthlyButton, annualButton].forEach {
            Utilities.styleHollowButton($0)
            $0.titleLabel?.numberOfLines = 0
            $0.titleLabel?.textAlignment = .center
            $0.contentEdgeInsets = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        }
        monthlyButton.addTarget(self, action: #selector(selectMonthly), for: .touchUpInside)
        annualButton.addTarget(self, action: #selector(selectAnnual), for: .touchUpInside)
        monthlyButton.setTitle("Monthly\nLoading…", for: .normal)
        annualButton.setTitle("Annual\nLoading…", for: .normal)
    }

    private func loadPackages() {
        IAPManager.shared.fetchPremiumPackages { [weak self] monthly, annual in
            DispatchQueue.main.async {
                guard let self else { return }
                self.monthlyPackage = monthly
                self.annualPackage = annual
                self.monthlyButton.setTitle(self.packageTitle(prefix: "Monthly", package: monthly), for: .normal)
                self.annualButton.setTitle(self.packageTitle(prefix: "Annual", package: annual), for: .normal)

                if let monthly {
                    self.select(package: monthly, button: self.monthlyButton)
                    self.packageStatusLabel.text = "Pick a plan, then continue with the App Store purchase flow."
                } else if let annual {
                    self.select(package: annual, button: self.annualButton)
                    self.packageStatusLabel.text = "Annual is ready while monthly finishes loading."
                } else {
                    self.packageStatusLabel.text = "Premium plans are unavailable right now. Try again in a moment."
                }
            }
        }
    }

    private func packageTitle(prefix: String, package: Package?) -> String {
        guard let package else { return "\(prefix)\nUnavailable" }
        return "\(prefix)\n\(package.storeProduct.localizedPriceString)"
    }

    private func select(package: Package, button: UIButton) {
        selectedPackage = package
        Utilities.styleHollowButton(monthlyButton)
        Utilities.styleHollowButton(annualButton)
        Utilities.styleFillButton2(button, color: AIcademyTheme.magenta)
        button.setTitleColor(.white, for: .normal)
        buyButton.setTitle("Continue with \(package.storeProduct.localizedTitle)", for: .normal)
    }

    
    
    @objc private func didTapBuyPremium() {
        guard let selectedPackage else {
            let alert = UIAlertController(title: "Premium Unavailable", message: "A premium plan has not loaded yet. Give the App Store a moment, then try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        IAPManager.shared.buyPremium(package: selectedPackage) { success in
            DispatchQueue.main.async {
                if success {
                    self.performSegue(withIdentifier: self.segueID ?? "unwindToMain", sender: self)
                } else {
                    let alert = UIAlertController(title: "Purchase Failed", message: "We were unable to complete the premium purchase right now.", preferredStyle: .alert)
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
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self?.performSegue(withIdentifier: self?.segueID ?? "unwindToMain", sender: self)
                    })
                    self?.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(title: "Nothing to Restore", message: "We could not find a previous premium purchase to restore.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                    self?.present(alert, animated: true)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        header.frame = CGRect(x: 22, y: view.safeAreaInsets.top + 18, width: view.width - 44, height: 180)
        headlineLabel.frame = CGRect(x: 24, y: header.bottom + 10, width: view.width - 48, height: 38)

        monthlyButton.frame = CGRect(x: 24, y: headlineLabel.bottom + 12, width: (view.width - 58) / 2, height: 82)
        annualButton.frame = CGRect(x: monthlyButton.frame.maxX + 10, y: headlineLabel.bottom + 12, width: (view.width - 58) / 2, height: 82)
        packageStatusLabel.frame = CGRect(x: 24, y: monthlyButton.frame.maxY + 8, width: view.width - 48, height: 38)
        heroView.frame = CGRect(x: 22, y: packageStatusLabel.frame.maxY + 6, width: view.width - 44, height: 150)

        termsView.frame = CGRect(x: 24, y: view.height-140, width: view.width - 48, height: 96)
        restorePurchases.frame = CGRect(x: 25, y: termsView.top - 40, width: view.width - 50, height: 30)
        buyButton.frame = CGRect(x: 25, y: restorePurchases.top - 60, width: view.width - 50, height: 50)
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

private extension PayWallViewController {
    @objc func selectMonthly() {
        guard let monthlyPackage else { return }
        select(package: monthlyPackage, button: monthlyButton)
    }

    @objc func selectAnnual() {
        guard let annualPackage else { return }
        select(package: annualPackage, button: annualButton)
    }
}
