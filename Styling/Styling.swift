//
//  Styling.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit

struct Styling {
    
    static let primaryColor = UIColor(red: 0.443, green: 0.788, blue: 0.808, alpha: 1.0)
    static let primaryBackgroundColor = UIColor(red: 0.651, green: 0.890, blue: 0.914, alpha: 1.0)
    
    static let primaryTextColor = UIColor.black
    
    static let titleFont = UIFont.boldSystemFont(ofSize: 24)
    static let bodyFont = UIFont.systemFont(ofSize: 15)
    
    static let cornerRadius: CGFloat = 10.0
    static let standardPadding: CGFloat = 32.0
    
    static func styleButton(_ button: UIButton, isTitle: Bool = false) {
        button.backgroundColor = primaryColor
        button.setTitleColor(primaryTextColor, for: .normal)
        button.layer.cornerRadius = cornerRadius
        button.titleLabel?.font = isTitle ? titleFont : bodyFont
    }
    
    static func styleLabel(_ label: UILabel) {
        label.textColor = primaryTextColor
        label.font = bodyFont
    }
    
    static func styleSegmentedControl(_ segmentedControl: UISegmentedControl) {
        segmentedControl.backgroundColor = primaryBackgroundColor
        segmentedControl.selectedSegmentTintColor = primaryColor
        segmentedControl.setTitleTextAttributes([.font: bodyFont, .foregroundColor: primaryTextColor], for: .normal)
    }
    
    static func styleSlider(_ slider: UISlider) {
        slider.tintColor = primaryTextColor.withAlphaComponent(0.5)
        slider.thumbTintColor = primaryColor
    }
}
