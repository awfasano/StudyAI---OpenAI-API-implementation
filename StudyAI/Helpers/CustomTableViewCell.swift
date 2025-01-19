//
//  CustomTableViewCell.swift
//  StudyAI
//
//  Created by Anthony Fasano on 3/14/23.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization cod
    }

    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var subjectImage: UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
