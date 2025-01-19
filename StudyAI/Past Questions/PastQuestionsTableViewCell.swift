//
//  PastQuestionsTableViewCell.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/20/23.
//

import UIKit

class PastQuestionsTableViewCell: UITableViewCell {

    @IBOutlet weak var questionTopic: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var typeOfQuestion: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
