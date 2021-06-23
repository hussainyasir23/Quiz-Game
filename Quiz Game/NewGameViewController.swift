//
//  NewGameViewController.swift
//  Quiz Game
//
//  Created by Mohammad on 22/06/21.
//

import UIKit

class NewGameViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let number = [10, 20, 30, 40, 50]
    let difficulty = ["Easy", "Medium", "Hard"]
    let category = ["General Knowledge", "Entertainment: Books", "Entertainment: Film", "Entertainment: Music", "Entertainment: Musicals & Theatres", "Entertainment: Television", "Entertainment: Video Games", "Entertainment: Board Games", "Science & Nature", "Science: Computers", "Science: Mathematics", "Mythology", "Sports", "Geography", "History", "Politics", "Art", "Celebrities", "Animals", "Vehicles", "Entertainment: Comics", "Science: Gadgets", "Entertainment: Japanese Anime & Manga", "Entertainment: Cartoon & Animations"]
    
    lazy var selectedNumber = number[0]
    lazy var selectedDifficulty = difficulty[0]
    lazy var selectedCategory = 9
    
    let numberLabel = UILabel()
    let difficultyLabel = UILabel()
    let categoryLabel = UILabel()
    
    let numberPicker = UIPickerView()
    let difficultyPicker = UIPickerView()
    let categoryPicker = UIPickerView()
    let selectionStack = UIStackView()
    
    let startButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setViews()
        setConstraints()
    }
    
    func setViews(){
        view.addSubview(selectionStack)
        
        selectionStack.addArrangedSubview(numberLabel)
        selectionStack.addArrangedSubview(numberPicker)
        selectionStack.addArrangedSubview(categoryLabel)
        selectionStack.addArrangedSubview(categoryPicker)
        selectionStack.addArrangedSubview(difficultyLabel)
        selectionStack.addArrangedSubview(difficultyPicker)
        selectionStack.addArrangedSubview(startButton)
    }
    
    func setConstraints(){
        
        view.backgroundColor = #colorLiteral(red: 0.6509803922, green: 0.8901960784, blue: 0.9137254902, alpha: 1)
        
        selectionStack.axis = .vertical
        selectionStack.distribution = .equalSpacing
        selectionStack.translatesAutoresizingMaskIntoConstraints = false
        selectionStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        selectionStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        selectionStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        selectionStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        numberLabel.text = "Number Of Questions:"
        numberLabel.font = .boldSystemFont(ofSize: 20)
        
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        difficultyLabel.text = "Select Difficulty:"
        difficultyLabel.font = .boldSystemFont(ofSize: 20)
        
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.text = "Select Category:"
        categoryLabel.font = .boldSystemFont(ofSize: 20)
        
        numberPicker.translatesAutoresizingMaskIntoConstraints = false
        numberPicker.delegate = self as UIPickerViewDelegate
        numberPicker.dataSource = self as UIPickerViewDataSource
        
        categoryPicker.translatesAutoresizingMaskIntoConstraints = false
        categoryPicker.delegate = self as UIPickerViewDelegate
        categoryPicker.dataSource = self as UIPickerViewDataSource
        
        difficultyPicker.translatesAutoresizingMaskIntoConstraints = false
        difficultyPicker.delegate = self as UIPickerViewDelegate
        difficultyPicker.dataSource = self as UIPickerViewDataSource
        
        startButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        startButton.titleLabel?.textAlignment = .center
        startButton.setTitleColor(.black, for: .normal)
        startButton.setTitle("Start!", for: .normal)
        startButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.heightAnchor.constraint(equalTo: startButton.widthAnchor, multiplier: 0.2).isActive = true
        startButton.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
    }
    
    @objc func startTapped(){
        
        var apiLink = "https://opentdb.com/api.php?type=boolean"
        apiLink += "&amount=" + String(selectedNumber)
        apiLink += "&difficulty=" + selectedDifficulty.lowercased()
        apiLink += "&category=" + String(selectedCategory + 9)
        
        let gameController = GameViewController()
        gameController.url = URL(string: apiLink)
        navigationController?.pushViewController(gameController, animated: true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == numberPicker {
            return number.count
        }
        else if pickerView == difficultyPicker {
            return difficulty.count
        }
        else{
            return category.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == numberPicker {
            return String(number[row])
        }
        else if pickerView == difficultyPicker {
            return difficulty[row]
        }
        else{
            return category[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == numberPicker {
            selectedNumber = number[row]
        }
        else if pickerView == difficultyPicker {
            selectedDifficulty = difficulty[row]
        }
        else{
            selectedCategory = row
        }
    }
}
