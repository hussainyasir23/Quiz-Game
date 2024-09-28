//
//  OptionSheetViewController.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import Foundation
import UIKit

protocol OptionSheetViewProtocol: AnyObject {
    func present(alert: UIAlertController, animated: Bool)
    func dismissViewController()
    func reloadTableView()
}

class OptionSheetViewController: UIViewController, OptionSheetViewProtocol {
    
    var presenter: OptionSheetPresenterProtocol
    private let titleString: String
    private lazy var requiresSearchBar: Bool = presenter.isSearchBarRequired()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = titleString
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        return tableView
    }()
    
    init(presenter: OptionSheetPresenterProtocol, title: String) {
        self.presenter = presenter
        self.titleString = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupSubviews()
    }
    
    private func configureView() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupSubviews() {
        addTitleLabel()
        if requiresSearchBar {
            addSearchContainer()
        }
        addTableView()
    }
    
    private func addTitleLabel() {
        view.addSubview(titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
    }
    
    private func addSearchContainer() {
        view.addSubview(searchContainer)
        searchContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        searchContainer.heightAnchor.constraint(equalToConstant: 68).isActive = true
        
        searchContainer.addSubview(searchBar)
        searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 8).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -8).isActive = true
        searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor).isActive = true
    }
    
    private func addTableView() {
        view.addSubview(tableView)
        if requiresSearchBar {
            tableView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor).isActive = true
        } else {
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16).isActive = true
        }
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32).isActive = true
        tableView.backgroundColor = .systemGroupedBackground
        addDismissKeyboardGesture()
    }
    
    private func addDismissKeyboardGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    public func dismissViewController() {
        dismiss(animated: true)
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
    
    func present(alert: UIAlertController, animated: Bool) {
        present(alert, animated: animated, completion: nil)
    }
}

extension OptionSheetViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNumberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configureCellSelectionState(cell, at: indexPath)
        configureCellCorners(cell, at: indexPath)
        configureCellSeparator(cell, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = presenter.getActionOption(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.image = option.image
        contentConfig.text = option.title
        //contentConfig.attributedText = option.title.getAttributedStringWithLocalized(with: searchBar.text, andFont: bold)
        //contentConfig.textProperties.color =
        //contentConfig.textProperties.font =
        
        cell.contentConfiguration = contentConfig
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.accessoryType = presenter.isSelected(at: indexPath) ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func configureCellSelectionState(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if presenter.isSelected(at: indexPath) {
            cell.setSelected(true, animated: false)
        }
    }
    
    private func configureCellCorners(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let isLastRow = indexPath.row == presenter.getNumberOfRows(in: indexPath.section) - 1
        let isFirstRowWithoutSearch = !requiresSearchBar && indexPath.row == 0
        
        if isLastRow || isFirstRowWithoutSearch {
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
            cell.layer.maskedCorners = {
                if isLastRow && isFirstRowWithoutSearch {
                    return [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                } else if isLastRow {
                    return [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                } else {
                    return [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                }
            }()
        } else {
            cell.layer.cornerRadius = 0
            cell.layer.masksToBounds = false
        }
    }
    
    private func configureCellSeparator(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let isLastRow = indexPath.row == presenter.getNumberOfRows(in: indexPath.section) - 1
        if isLastRow {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            if let contentConfig = cell.contentConfiguration as? UIListContentConfiguration,
               let image = contentConfig.image {
                cell.separatorInset = UIEdgeInsets(top: 0, left: image.size.width + 32, bottom: 0, right: 0)
            } else {
                cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
            }
        }
    }
}

extension OptionSheetViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.searchBarTextDidChange(to: searchText)
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        styleCancelButton(searchBar)
        addClearButtonTarget(searchBar)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        presenter.searchBarTextDidChange(to: "")
        tableView.reloadData()
    }
    
    private func styleCancelButton(_ searchBar: UISearchBar) {
        if let cancelButton = searchBar.value(forKey: OptionSheetConstants.cancelButton) as? UIButton {
            cancelButton.setTitleColor(.systemBlue, for: .normal)
        }
    }
    
    private func addClearButtonTarget(_ searchBar: UISearchBar) {
        if let textFieldInsideSearchBar = searchBar.value(forKey: OptionSheetConstants.searchField) as? UITextField,
           let clearButton = textFieldInsideSearchBar.value(forKey: OptionSheetConstants.clearButton) as? UIButton {
            clearButton.addTarget(self, action: #selector(resetSearchBar), for: .touchUpInside)
        }
    }
    
    @objc private func resetSearchBar() {
        searchBar(searchBar, textDidChange: "")
    }
}

struct OptionSheetConstants {
    static let cancelButton = "cancelButton"
    static let searchField = "searchField"
    static let clearButton = "clearButton"
    static let searchNoData = "search_nodata"
}
