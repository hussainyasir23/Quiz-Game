//
//  OptionSheetViewController.swift
//  Quiz Game
//
//  Created by Yasir on 28/09/24.
//

import Foundation
import UIKit

protocol OptionSheetViewProtocol: AnyObject {
    func dismissViewController()
}

class OptionSheetViewController: UIViewController, OptionSheetViewProtocol {
    
    // MARK: - Properties
    
    private let presenter: OptionSheetPresenterProtocol
    private let titleString: String
    private lazy var requiresSearchBar: Bool = presenter.isSearchBarRequired()
    
    // MARK: - UI Elements
    
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
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
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
        tableView.backgroundColor = .systemGroupedBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellIdentifier")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Initializer
    
    init(presenter: OptionSheetPresenterProtocol, title: String) {
        self.presenter = presenter
        self.titleString = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setupSubviews()
    }
    
    // MARK: - Setup Methods
    
    private func configureView() {
        view.backgroundColor = .systemGroupedBackground
    }
    
    private func setupSubviews() {
        setupTitleLabel()
        if requiresSearchBar {
            setupSearchContainer()
        }
        setupTableView()
        addDismissKeyboardGesture()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setupSearchContainer() {
        view.addSubview(searchContainer)
        NSLayoutConstraint.activate([
            searchContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchContainer.heightAnchor.constraint(equalToConstant: 68)
        ])
        
        searchContainer.addSubview(searchBar)
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -8),
            searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -32),
            tableView.topAnchor.constraint(equalTo: requiresSearchBar ? searchContainer.bottomAnchor : titleLabel.bottomAnchor, constant: requiresSearchBar ? 0 : 16)
        ])
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
}

extension OptionSheetViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNumberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = presenter.getActionOption(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        let defaultFont = UIFont.preferredFont(forTextStyle: .body)
        let boldFont = UIFont.boldSystemFont(ofSize: defaultFont.pointSize)
        
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.attributedText = option.title.attributedStringWithBoldSearchText(searchBar.text, defaultFont: defaultFont, boldFont: boldFont)
        contentConfig.image = option.image
        
        cell.contentConfiguration = contentConfig
        cell.backgroundColor = .secondarySystemGroupedBackground
        cell.accessoryType = presenter.isSelected(at: indexPath) ? .checkmark : .none
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = .systemBlue.withAlphaComponent(0.15)
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configureCellSelectionState(cell, at: indexPath)
        configureCellCorners(cell, at: indexPath)
        configureCellSeparator(cell, at: indexPath)
    }
    
    private func configureCellSelectionState(_ cell: UITableViewCell, at indexPath: IndexPath) {
        if presenter.isSelected(at: indexPath) {
            cell.setSelected(true, animated: false)
        }
    }
    
    private func configureCellCorners(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let isLastRow = indexPath.row == presenter.getNumberOfRows(in: indexPath.section) - 1
        let isFirstRowWithoutSearch = !requiresSearchBar && indexPath.row == 0
        
        var corners: CACornerMask = []
        
        if isFirstRowWithoutSearch {
            corners.insert([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        }
        
        if isLastRow {
            corners.insert([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }
        
        if !corners.isEmpty {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = corners
            cell.layer.masksToBounds = true
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
        guard let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton else {
            return
        }
        cancelButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    private func addClearButtonTarget(_ searchBar: UISearchBar) {
        guard let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField,
              let clearButton = textFieldInsideSearchBar.value(forKey: "clearButton") as? UIButton else {
            return
        }
        clearButton.addTarget(self, action: #selector(resetSearchBar), for: .touchUpInside)
    }
    
    @objc private func resetSearchBar() {
        searchBar(searchBar, textDidChange: "")
    }
}
