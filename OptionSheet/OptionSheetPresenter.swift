//
//  OptionSheetPresenter.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import Foundation
import UIKit

protocol OptionSheetPresenterProtocol {
    func isSearchBarRequired() -> Bool
    func getNumberOfRows(in section: Int) -> Int
    func isSelected(at indexPath: IndexPath) -> Bool
    func getActionOption(at indexPath: IndexPath) -> Option
    func didSelectRow(at indexPath: IndexPath)
    func searchBarTextDidChange(to searchText: String)
}

class OptionSheetPresenter: OptionSheetPresenterProtocol {
    
    private let options: [Option]
    private var displayOptions: [Option]
    private let selectionCallback: (Option) -> Void
    
    weak var view: OptionSheetViewProtocol?
    private var selectedValue: String
    
    init(options: [Option], selectedValue: String, selectionCallback: @escaping (Option) -> Void) {
        self.options = options
        self.displayOptions = options
        self.selectedValue = selectedValue
        self.selectionCallback = selectionCallback
    }
    
    func isSearchBarRequired() -> Bool {
        return options.count > 4 ? true : false
    }
    
    func getNumberOfRows(in section: Int) -> Int {
        return displayOptions.count
    }
    
    func isSelected(at indexPath: IndexPath) -> Bool {
        return displayOptions[indexPath.row].title == selectedValue
    }
    
    func getActionOption(at indexPath: IndexPath) -> Option {
        return displayOptions[indexPath.row]
    }
    
    func searchBarTextDidChange(to searchText: String) {
        displayOptions = searchText.isEmpty ? options : options.filter { $0.title.localizedLowercase.contains(searchText.localizedLowercase) }
    }
    
    func didSelectRow(at indexPath: IndexPath) {
        selectionCallback(displayOptions[indexPath.row])
        view?.dismissViewController()
    }
}
