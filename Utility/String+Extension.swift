//
//  String+Extension.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import Foundation
import UIKit

extension String {
    
    func attributedStringWithBoldSearchText(_ searchText: String?, defaultFont: UIFont, boldFont: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self, attributes: [.font: defaultFont])
        
        guard let searchText = searchText?.lowercased(), !searchText.isEmpty else {
            return attributedString
        }
        
        let lowercasedString = self.lowercased()
        if let range = lowercasedString.range(of: searchText) {
            let nsRange = NSRange(range, in: self)
            attributedString.addAttributes([.font: boldFont], range: nsRange)
        }
        
        return attributedString
    }
}
