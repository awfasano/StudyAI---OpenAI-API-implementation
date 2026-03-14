//
//  PayWallHeaderView.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/13/23.
//

import UIKit

class PayWallHeaderView: UIView {
    private let headerImageView:UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "appicon.jpeg"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(headerImageView)
        layer.cornerRadius = 34
        layer.borderWidth = 2
        layer.borderColor = AIcademyTheme.ink.cgColor
        backgroundColor = AIcademyTheme.softSurface
    }
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerImageView.frame = CGRect(x: (bounds.width - 164)/2, y: 18, width: 164, height: bounds.height - 36)
    }
    

}
