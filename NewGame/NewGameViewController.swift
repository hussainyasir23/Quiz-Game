//
//  NewGameViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit
import Combine

class NewGameViewController: UIViewController {
    
    private let viewModel: NewGameViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private let difficultySegmentedControl = UISegmentedControl()
    private let typeSegmentedControl = UISegmentedControl()
    private let questionCountSlider = UISlider()
    private let questionCountLabel = UILabel()
    private let categoryButton = UIButton()
    private let startButton = UIButton()
    
    init(viewModel: NewGameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "New Game Setup"
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        [difficultySegmentedControl, typeSegmentedControl, questionCountSlider, questionCountLabel, categoryButton, startButton].forEach {
            stackView.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        setupDifficultyControl()
        setupTypeControl()
        setupQuestionCountControl()
        setupCategoryButton()
        setupStartButton()
    }
    
    private func setupDifficultyControl() {
        difficultySegmentedControl.removeAllSegments()
        viewModel.difficulties.enumerated().forEach { index, difficulty in
            difficultySegmentedControl.insertSegment(withTitle: difficulty.displayName, at: index, animated: false)
        }
        difficultySegmentedControl.selectedSegmentIndex = 0
        difficultySegmentedControl.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
    }
    
    private func setupTypeControl() {
        typeSegmentedControl.removeAllSegments()
        viewModel.questionTypes.enumerated().forEach { index, type in
            typeSegmentedControl.insertSegment(withTitle: type.displayName, at: index, animated: false)
        }
        typeSegmentedControl.selectedSegmentIndex = 0
        typeSegmentedControl.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
    }
    
    private func setupQuestionCountControl() {
        questionCountSlider.minimumValue = Float(viewModel.questionCountsMin)
        questionCountSlider.maximumValue = Float(viewModel.questionCountsMax)
        questionCountSlider.value = Float(viewModel.selectedQuestionCount)
        questionCountSlider.addTarget(self, action: #selector(questionCountChanged), for: .valueChanged)
        
        questionCountLabel.text = "Number of Questions: \(viewModel.selectedQuestionCount)"
        questionCountLabel.textAlignment = .center
    }
    
    private func setupCategoryButton() {
        categoryButton.setTitle("Select Category", for: .normal)
        categoryButton.setTitleColor(.systemBlue, for: .normal)
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
    }
    
    private func setupStartButton() {
        startButton.setTitle("Start Quiz", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.backgroundColor = .systemBlue
        startButton.layer.cornerRadius = 10
        startButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        startButton.addTarget(self, action: #selector(startQuizTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.categoryButton.setTitle(category.name, for: .normal)
            }
            .store(in: &cancellables)
    }
    
    @objc private func difficultyChanged() {
        viewModel.selectedDifficulty = viewModel.difficulties[difficultySegmentedControl.selectedSegmentIndex]
    }
    
    @objc private func typeChanged() {
        viewModel.selectedQuestionType = viewModel.questionTypes[typeSegmentedControl.selectedSegmentIndex]
    }
    
    @objc private func questionCountChanged() {
        let count = Int(questionCountSlider.value)
        viewModel.selectedQuestionCount = count
        questionCountLabel.text = "Number of Questions: \(count)"
    }
    
    @objc private func categoryTapped() {
        let categoryVC = CategorySelectionViewController(categories: viewModel.categories, selectedCategory: viewModel.selectedCategory) { [weak self] category in
            self?.viewModel.selectedCategory = category
        }
        let navController = UINavigationController(rootViewController: categoryVC)
        present(navController, animated: true)
    }
    
    @objc private func startQuizTapped() {
        viewModel.startQuiz()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.showError(error)
                }
            } receiveValue: { quiz in
                self.startGame(with: quiz)
            }
            .store(in: &cancellables)
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func startGame(with quiz: Quiz) {
        let gameViewModel = GameViewModel(quiz: quiz)
        let gameViewController = GameViewController(viewModel: gameViewModel)
        navigationController?.pushViewController(gameViewController, animated: true)
    }
}
