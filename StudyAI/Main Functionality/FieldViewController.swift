//
//  FieldViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/15/23.
//

import UIKit

class FieldViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let fieldsHeaderTag = 8_301

    @IBOutlet weak var tableView: UITableView!
    var subject:String?
    var selectedField:String?
    var uiColor:UIColor?
    var fields = ["Math":["Algebra", "Geometry", "Trigonometry","Calculus","Statistics and Probability"],
                  "Science":["Biology", "Chemistry", "Physics", "Earth Science", "Environmental Science"],
                  "Social Sciences":["Macroeconomics", "Microeconomics", "Psychology", "Government", "Geography"],
                  "History":["US History", "European History","World History", "Art History"],
                  "English":["Poetry", "Essays", "Grammar"]
    ]
    //Foriegn Languages":["Spanish","French","Japanese","Chinese","German","Korean"]
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        view.backgroundColor = .clear
        
        if subject == nil || uiColor == nil {
            let alertController = UIAlertController(title: "Error", message: "Getting your information", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .default)
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            navigationController?.popViewController(animated: true)
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        installHeaderIfNeeded()
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let subjectCell = subject else {
                return CustomTableViewCell()
            }
        guard let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as? CustomTableViewCell else {
            return UITableViewCell()
        }

        let view = UIView()
        view.layer.cornerRadius = 0

        cell.subject.text = fields[subjectCell]?[indexPath.section]
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = AIcademyTheme.surface
        cell.contentView.layer.cornerRadius = 24
        cell.contentView.layer.borderWidth = 2
        cell.contentView.layer.borderColor = (uiColor ?? AIcademyTheme.border).cgColor
        cell.contentView.layer.masksToBounds = true
        cell.subject.font = .systemFont(ofSize: 24, weight: .heavy)
        view.backgroundColor = uiColor?.adjustBrightness(by: 25)
        cell.subject.textColor = uiColor
        cell.selectedBackgroundView = view
        
        switch subjectCell {
        case "Math":
            view.backgroundColor = uiColor?.adjustBrightness(by: 65)
            cell.selectedBackgroundView = view
      
        case "Science":
            view.backgroundColor = uiColor?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view
            
        case "Foreign Languages":
            view.backgroundColor  = uiColor?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view

        case "Social Sciences":
            view.backgroundColor = uiColor?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view
            
        case "English":
            view.backgroundColor = uiColor?.adjustBrightness(by: 100).withAlphaComponent(0.5)
            cell.selectedBackgroundView = view
            
        case "History":
            view.backgroundColor = uiColor?.adjustBrightness(by: 50)
            cell.selectedBackgroundView = view

        default:
            break
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let subjectCell = subject else {
                return 0
            }
        guard fields[subjectCell] != nil else {
            return 0
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fields[subject ?? ""]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        selectedField = fields[subject ?? ""]?[indexPath.section]
    
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        88
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if subject == "English" && selectedField == "Grammar"{
            performSegue(withIdentifier: "toFixGrammar", sender: self)
        }
        else {
            performSegue(withIdentifier: "toMain", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if(segue.identifier == "toMain"){
            guard let viewcontroller = segue.destination as? MainViewController else { return }
            viewcontroller.subject = subject
            viewcontroller.field = selectedField
            viewcontroller.uiColor = uiColor

        }
        else if(segue.identifier == "tofixGrammar") {
            let _ = segue.destination as? FixGrammarViewController
        }
    }

    private func installHeaderIfNeeded() {
        guard tableView.tableHeaderView?.tag != fieldsHeaderTag else { return }

        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 196))
        header.tag = fieldsHeaderTag
        header.backgroundColor = .clear

        let card = UIView(frame: CGRect(x: 20, y: 12, width: header.bounds.width - 40, height: 168))
        AIcademyTheme.styleSurface(card, tint: uiColor)
        card.autoresizingMask = [.flexibleWidth]

        let imageView = UIImageView(frame: CGRect(x: 18, y: 20, width: 88, height: 88))
        Utilities.applyHeroImage(imageView)
        card.addSubview(imageView)

        let title = UILabel(frame: CGRect(x: 118, y: 24, width: card.bounds.width - 136, height: 32))
        title.autoresizingMask = [.flexibleWidth]
        title.text = "\(subject ?? "Study") paths"
        AIcademyTheme.styleTitle(title, size: 28)
        card.addSubview(title)

        let subtitle = UILabel(frame: CGRect(x: 118, y: 60, width: card.bounds.width - 136, height: 52))
        subtitle.autoresizingMask = [.flexibleWidth]
        subtitle.numberOfLines = 0
        subtitle.text = "Choose the specific field you want Carlisle to generate for next."
        AIcademyTheme.styleSubtitle(subtitle, size: 14)
        card.addSubview(subtitle)

        header.addSubview(card)
        tableView.tableHeaderView = header
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
