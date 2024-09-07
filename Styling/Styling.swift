//
//  Styling.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit

struct Styling {
    
    static let primaryColor = UIColor(red: 0.443, green: 0.788, blue: 0.808, alpha: 1.0)
    static let backgroundColor = UIColor(red: 0.651, green: 0.890, blue: 0.914, alpha: 1.0)
    static let textColor = UIColor.black
    
    static let titleFont = UIFont.boldSystemFont(ofSize: 24)
    static let bodyFont = UIFont.systemFont(ofSize: 18)
    
    static let cornerRadius: CGFloat = 10.0
    static let standardPadding: CGFloat = 32.0
    
    static func styleButton(_ button: UIButton) {
        button.backgroundColor = primaryColor
        button.setTitleColor(textColor, for: .normal)
        button.layer.cornerRadius = cornerRadius
        button.titleLabel?.font = titleFont
    }
    
    static func styleLabel(_ label: UILabel) {
        label.textColor = textColor
        label.font = bodyFont
    }
}
