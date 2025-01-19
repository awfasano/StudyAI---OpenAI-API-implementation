//
//  PayWallHeaderView.swift
//  StudyAI
//
//  Created by Anthony Fasano on 4/13/23.
//

import UIKit

class PayWallHeaderView: UIView {
    let color = UIColor.init(hue: 0.0333, saturation: 0, brightness: 0.3, alpha: 1.0)

    
    private let headerImageView:UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "crown.fill"))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 0, width: 110, height: 110)
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(headerImageView)
        backgroundColor = color
    }
    required init(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerImageView.frame = CGRect(x: (Int(bounds.width) - 110)/2, y: Int((bounds.height)-110)/2, width: 110, height: 110)
    }
    

}
