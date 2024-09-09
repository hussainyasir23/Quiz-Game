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
    private var cancellables = Set<AnyCancellable>()
    
    private let contentView = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let difficultySegmentedControl = UISegmentedControl()
    private let typeSegmentedControl = UISegmentedControl()
    private let questionCountSlider = UISlider()
    private let questionCountLabel = UILabel()
    private let categoryButton = UIButton(type: .system)
    private let startButton = UIButton(type: .system)
    
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
        setupNavigation()
        bindViewModel()
    }
    
    private func setupUI() {
        view.backgroundColor = Styling.primaryBackgroundColor
        title = "New Game Setup"
        
        view.addSubview(contentView)
        view.addSubview(activityIndicator)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        setupStackView()
        setupControls()
    }
    
    private func setupNavigation() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )
        navigationController?.navigationBar.tintColor = Styling.primaryTextColor
    }
    
    private func setupStackView() {
        let stackView = UIStackView(arrangedSubviews: [
            difficultySegmentedControl,
            typeSegmentedControl,
            questionCountSlider,
            questionCountLabel,
            categoryButton,
            startButton
        ])
        stackView.axis = .vertical
        stackView.spacing = Styling.standardPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: Styling.standardPadding),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Styling.standardPadding),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Styling.standardPadding),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Styling.standardPadding),
        ])
    }
    
    private func setupControls() {
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
        difficultySegmentedControl.backgroundColor = Styling.primaryBackgroundColor
        difficultySegmentedControl.selectedSegmentTintColor = Styling.primaryColor
        difficultySegmentedControl.setTitleTextAttributes([.font: Styling.bodyFont,
                                                           .foregroundColor: Styling.primaryTextColor],
                                                          for: .normal)
    }
    
    private func setupTypeControl() {
        typeSegmentedControl.removeAllSegments()
        viewModel.questionTypes.enumerated().forEach { index, type in
            typeSegmentedControl.insertSegment(withTitle: type.displayName, at: index, animated: false)
        }
        typeSegmentedControl.selectedSegmentIndex = 0
        typeSegmentedControl.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        typeSegmentedControl.backgroundColor = Styling.primaryBackgroundColor
        typeSegmentedControl.selectedSegmentTintColor = Styling.primaryColor
        typeSegmentedControl.setTitleTextAttributes([.font: Styling.bodyFont,
                                                           .foregroundColor: Styling.primaryTextColor],
                                                          for: .normal)
    }
    
    private func setupQuestionCountControl() {
        questionCountSlider.minimumValue = Float(viewModel.questionCountsMin)
        questionCountSlider.maximumValue = Float(viewModel.questionCountsMax)
        questionCountSlider.value = Float(viewModel.selectedQuestionCount)
        questionCountSlider.addTarget(self, action: #selector(questionCountChanged), for: .valueChanged)
        questionCountSlider.tintColor = Styling.primaryTextColor.withAlphaComponent(0.5)
        questionCountSlider.thumbTintColor = Styling.primaryColor
        
        questionCountLabel.text = "Number of Questions: \(viewModel.selectedQuestionCount)"
        questionCountLabel.textAlignment = .center
        questionCountLabel.font = Styling.bodyFont
        questionCountLabel.textColor = Styling.primaryTextColor
    }
    
    private func setupCategoryButton() {
        categoryButton.setTitle("Select Category", for: .normal)
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        categoryButton.backgroundColor = Styling.primaryColor
        categoryButton.setTitleColor(Styling.primaryTextColor, for: .normal)
        categoryButton.layer.cornerRadius = Styling.cornerRadius
        categoryButton.titleLabel?.font = Styling.bodyFont
    }
    
    private func setupStartButton() {
        startButton.setTitle("Start Quiz", for: .normal)
        startButton.addTarget(self, action: #selector(startQuizTapped), for: .touchUpInside)
        startButton.backgroundColor = Styling.primaryColor
        startButton.setTitleColor(Styling.primaryTextColor, for: .normal)
        startButton.layer.cornerRadius = Styling.cornerRadius
        startButton.titleLabel?.font = Styling.titleFont
        startButton.heightAnchor.constraint(equalTo: startButton.widthAnchor, multiplier: 0.15).isActive = true
    }
    
    private func bindViewModel() {
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.categoryButton.setTitle(category.displayName, for: .normal)
            }
            .store(in: &cancellables)
    }
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
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
        startButton.isEnabled = false
        contentView.isHidden = true
        activityIndicator.startAnimating()
        viewModel.startQuiz()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.startButton.isEnabled = true
                self?.activityIndicator.stopAnimating()
                self?.contentView.isHidden = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.showError(error)
                }
            } receiveValue: { [weak self] quiz in
                self?.startGame(with: quiz)
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
