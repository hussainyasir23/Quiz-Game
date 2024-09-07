//
//  CategorySelectionViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit

class CategorySelectionViewController: UITableViewController {
    
    private let categories: [Category]
    private var selectedCategory: Category
    private let selectionCallback: (Category) -> Void
    
    init(categories: [Category], selectedCategory: Category, selectionCallback: @escaping (Category) -> Void) {
        self.categories = categories
        self.selectedCategory = selectedCategory
        self.selectionCallback = selectionCallback
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = Styling.primaryBackgroundColor
        title = "Select Category"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category = categories[indexPath.row]
        configureCell(cell, with: category)
        return cell
    }
    
    private func configureCell(_ cell: UITableViewCell, with category: Category) {
        cell.textLabel?.text = category.displayName
        cell.accessoryType = category == selectedCategory ? .checkmark : .none
        cell.backgroundColor = Styling.primaryBackgroundColor
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        selectionCallback(selectedCategory)
        tableView.reloadData()
        dismiss(animated: true)
    }
}
