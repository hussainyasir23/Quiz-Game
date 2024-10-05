//
//  OptionSheetAssembler.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import Foundation

class OptionSheetAssembler {
    
    static func getOptionSheetViewController(with options: [Option], title: String, selectedValue: String, selectionCallback: @escaping (Option) -> Void) -> OptionSheetViewController {
        
        let presenter = OptionSheetPresenter(options: options, selectedValue: selectedValue, selectionCallback: selectionCallback)
        let viewController = OptionSheetViewController(presenter: presenter, title: title)
        presenter.view = viewController
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        return viewController
    }
}
