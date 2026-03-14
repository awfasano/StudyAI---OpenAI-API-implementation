//
//  PastCallsViewController.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/28/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class PastCallsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,reloadDelegate {
    private let pastHeaderTag = 8_111

    
    @IBOutlet weak var tableView: UITableView!
    
    var fields = ["Math":["Algebra", "Geometry", "Trigonometry","Calculus","Statistics and Probability"],
                  "Science":["Biology", "Chemistry", "Physics", "Earth Science", "Environmental Science"],
                  "Social Sciences":["Macroeconomics", "Microeconomics", "Psychology", "Government", "Geography"],
                  "History":["US History", "European History","World History", "Art History"],
                  "English":["Poetry", "Essays", "Grammar"],
                  "Foreign Languages":["Spanish","French","Japanese","Chinese","German","Korean"]
    ]
    var selectedSubject:String?
    var selectedField:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AIcademyTheme.applyBackground(to: view)
        view.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        installHeaderIfNeeded()
        
        // Do any additional setup after loading the view.
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let keys = Array(fields.keys)
        guard let fields = fields[keys[indexPath.section]]?[indexPath.row] else{
            return cell
        }
        
        var config = UIListContentConfiguration.cell()
        
        
        config.text = fields
        config.textProperties.color = AIcademyTheme.ink
        config.textProperties.font = .systemFont(ofSize: 18, weight: .bold)
        //config.secondaryText = ""
        cell.contentConfiguration = config
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = AIcademyTheme.surface
        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.borderWidth = 2
        cell.contentView.layer.borderColor = AIcademyTheme.border.cgColor
            return cell
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let fieldsKeys = Array(fields.keys)
        return fields[fieldsKeys[section]]?.count ?? 0
    }
        
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let fieldsKeys = Array(fields.keys)
        return fieldsKeys[section]
    }
        
    func numberOfSections(in tableView: UITableView) -> Int {
            return fields.keys.count
    }
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let keys = Array(fields.keys)
        selectedField = fields[keys[indexPath.section]]?[indexPath.row]
        selectedSubject = keys[indexPath.section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toPastQuestionsView", sender: self)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 22)
        header.textLabel?.frame = header.bounds
        header.textLabel?.textAlignment = .left
        header.textLabel?.textColor = AIcademyTheme.ink
        header.tintColor = .clear
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        58
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        48
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toPastQuestionsView"){
            guard let viewcontroller = segue.destination as? PastDocumentListViewController else { return }
            viewcontroller.subject = selectedSubject
            viewcontroller.field = selectedField
        }
    }
    
    func showAlert(title:String,msg:String) {
        let cancel1 = UIAlertAction(title: "OK", style: .cancel){ (action) in
            
        }
        let ac1 = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        ac1.addAction(cancel1)
        self.present(ac1, animated: true)
    }
    
    func reload(success: Bool) {
        if success {

        }
        else {
            
        }
    }

    private func installHeaderIfNeeded() {
        guard tableView.tableHeaderView?.tag != pastHeaderTag else { return }

        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 188))
        header.tag = pastHeaderTag
        header.backgroundColor = .clear

        let card = UIView(frame: CGRect(x: 20, y: 12, width: header.bounds.width - 40, height: 160))
        AIcademyTheme.styleSurface(card, tint: AIcademyTheme.orange)
        card.autoresizingMask = [.flexibleWidth]

        let imageView = UIImageView(frame: CGRect(x: 18, y: 18, width: 86, height: 86))
        Utilities.applyHeroImage(imageView)
        card.addSubview(imageView)

        let title = UILabel(frame: CGRect(x: 118, y: 24, width: card.bounds.width - 136, height: 32))
        title.autoresizingMask = [.flexibleWidth]
        title.text = "Past Questions"
        AIcademyTheme.styleTitle(title, size: 28)
        card.addSubview(title)

        let subtitle = UILabel(frame: CGRect(x: 118, y: 58, width: card.bounds.width - 136, height: 48))
        subtitle.autoresizingMask = [.flexibleWidth]
        subtitle.numberOfLines = 0
        subtitle.text = "Browse saved study material by subject and jump back into older work."
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
