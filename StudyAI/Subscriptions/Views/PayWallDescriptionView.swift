//
//  PayWallDescriptionView.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/13/23.
//

import UIKit

class PayWallDescriptionView: UIView {

    private let descriptorLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.numberOfLines = 0
        label.text = "Unlock brighter study sessions, more generations, and more time with Carlisle."
        label.textColor = AIcademyTheme.ink

        return label
    }()
    
    private let priceLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        label.text = "Premium plans available"
        label.textColor = AIcademyTheme.magenta
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        AIcademyTheme.styleSurface(self)
        addSubview(priceLabel)
        addSubview(descriptorLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        descriptorLabel.frame = CGRect(x: 20, y: 0, width: width-40, height: height/2)
        priceLabel.frame = CGRect(x: 20, y: height/2, width: width-40, height: height/2)

    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
