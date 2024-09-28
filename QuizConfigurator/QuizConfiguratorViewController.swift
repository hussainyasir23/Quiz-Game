//
//  QuizConfiguratorViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit
import Combine

class QuizConfiguratorViewController: UIViewController {
    
    private let viewModel: QuizConfiguratorViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView =  {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Styling.standardPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let loadingOverlay = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    private let difficultySegmentedControl = UISegmentedControl()
    private let typeSegmentedControl = UISegmentedControl()
    private let questionCountSlider = UISlider()
    private let questionCountLabel = UILabel()
    private let categoryButton = UIButton(type: .system)
    
    private lazy var beginButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Begin Quiz"
        button.configuration?.image = UIImage(systemName: "play.fill")
        button.configuration?.imagePadding = 8
        button.configuration?.cornerStyle = .large
        button.configuration?.baseBackgroundColor = .systemGreen
        button.configuration?.baseForegroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(beginQuizTapped), for: .touchUpInside)
        button.accessibilityLabel = "Begin Quiz"
        button.accessibilityHint = "Starts the quiz with the selected configuration"
        return button
    }()
    
    init(viewModel: QuizConfiguratorViewModel) {
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
        view.backgroundColor = .systemGroupedBackground
        title = "Configure Quiz"
        
        setupScrollView()
        setupStackView()
        setupControls()
        setupActivityIndicator()
        setupLoadingOverlay()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupStackView() {
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Styling.standardPadding),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Styling.standardPadding),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -Styling.standardPadding),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -Styling.standardPadding),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -2 * Styling.standardPadding)
        ])
    }
    
    private func setupControls() {
        addCardControlGroup(header: "Difficulty", control: setupDifficultyControl())
        addCardControlGroup(header: "Question Type", control: setupTypeControl())
        addCardControlGroup(header: "Number of Questions", control: setupQuestionCountControl())
        addCardControlGroup(header: "Category", control: setupCategoryButton())
        
        stackView.addArrangedSubview(beginButton)
        NSLayoutConstraint.activate([
            beginButton.heightAnchor.constraint(equalToConstant: 50),
            beginButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.7)
        ])
    }
    
    private func addCardControlGroup(header: String, control: UIView) {
        let cardView = UIView()
        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.label.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1
        
        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = Styling.standardPadding / 2
        contentStack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        contentStack.isLayoutMarginsRelativeArrangement = true
        
        let headerLabel = createSectionHeader(title: header)
        contentStack.addArrangedSubview(headerLabel)
        contentStack.addArrangedSubview(control)
        
        cardView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
        ])
        
        stackView.addArrangedSubview(cardView)
        cardView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
    }
    
    private func createSectionHeader(title: String) -> UILabel {
        let headerLabel = UILabel()
        headerLabel.text = title
        headerLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        headerLabel.textColor = .label
        return headerLabel
    }
    
    private func setupDifficultyControl() -> UISegmentedControl {
        difficultySegmentedControl.removeAllSegments()
        viewModel.difficulties.enumerated().forEach { index, difficulty in
            difficultySegmentedControl.insertSegment(withTitle: difficulty.displayName, at: index, animated: false)
        }
        difficultySegmentedControl.selectedSegmentIndex = 0
        difficultySegmentedControl.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        difficultySegmentedControl.selectedSegmentTintColor = .systemBlue
        difficultySegmentedControl.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label
        ], for: .normal)
        difficultySegmentedControl.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.white
        ], for: .selected)
        difficultySegmentedControl.accessibilityLabel = "Difficulty"
        return difficultySegmentedControl
    }
    
    private func setupTypeControl() -> UISegmentedControl {
        typeSegmentedControl.removeAllSegments()
        viewModel.questionTypes.enumerated().forEach { index, type in
            typeSegmentedControl.insertSegment(withTitle: type.displayName, at: index, animated: false)
        }
        typeSegmentedControl.selectedSegmentIndex = 0
        typeSegmentedControl.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        typeSegmentedControl.selectedSegmentTintColor = .systemBlue
        typeSegmentedControl.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label
        ], for: .normal)
        typeSegmentedControl.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.white
        ], for: .selected)
        typeSegmentedControl.accessibilityLabel = "Question Type"
        return typeSegmentedControl
    }
    
    private func setupQuestionCountControl() -> UIStackView {
        let controlStack = UIStackView()
        controlStack.axis = .vertical
        controlStack.spacing = Styling.standardPadding / 4
        
        questionCountSlider.minimumValue = Float(viewModel.questionCountsMin)
        questionCountSlider.maximumValue = Float(viewModel.questionCountsMax)
        questionCountSlider.value = Float(viewModel.selectedQuestionCount)
        questionCountSlider.addTarget(self, action: #selector(questionCountChanged), for: .valueChanged)
        questionCountSlider.tintColor = .systemBlue
        questionCountSlider.accessibilityLabel = "Number of Questions"
        
        questionCountLabel.text = "Number of Questions: \(viewModel.selectedQuestionCount)"
        questionCountLabel.textAlignment = .center
        questionCountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        questionCountLabel.adjustsFontForContentSizeCategory = true
        questionCountLabel.textColor = .label
        
        controlStack.addArrangedSubview(questionCountSlider)
        controlStack.addArrangedSubview(questionCountLabel)
        
        return controlStack
    }
    
    private func setupCategoryButton() -> UIButton {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Select Category"
        configuration.image = UIImage(systemName: "chevron.down")?
            .withConfiguration(UIImage.SymbolConfiguration(scale: .small))
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 8
        configuration.cornerStyle = .medium
        configuration.baseBackgroundColor = .systemBlue
        configuration.baseForegroundColor = .white
        
        categoryButton.configuration = configuration
        categoryButton.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        categoryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        categoryButton.accessibilityLabel = "Category"
        categoryButton.accessibilityHint = "Select a category for your quiz"
        return categoryButton
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
        navigationController?.navigationBar.tintColor = .label
    }
    
    private func setupActivityIndicator() {
        loadingOverlay.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = Styling.primaryColor
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }
    
    private func setupLoadingOverlay() {
        view.addSubview(loadingOverlay)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.backgroundColor = Styling.primaryBackgroundColor.withAlphaComponent(0.5)
        loadingOverlay.isHidden = true
        
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        animateSelection(difficultySegmentedControl)
    }
    
    @objc private func typeChanged() {
        viewModel.selectedQuestionType = viewModel.questionTypes[typeSegmentedControl.selectedSegmentIndex]
        viewModel.selectedQuestionType = viewModel.questionTypes[typeSegmentedControl.selectedSegmentIndex]
        animateSelection(typeSegmentedControl)
    }
    
    @objc private func questionCountChanged() {
        let count = Int(questionCountSlider.value)
        viewModel.selectedQuestionCount = count
        questionCountLabel.text = "Number of Questions: \(count)"
    }
    
    @objc private func categoryTapped() {
        let options = viewModel.categories.map { Option(title: $0.displayName, image: nil) }
        let optionSheetViewController = OptionSheetAssembler.getOptionSheetViewController(with: options, title: "Select Category", selectedValue: viewModel.selectedCategory.displayName) { [weak self] option in
            if let selectedCategory = self?.viewModel.categories.first(where: { $0.displayName == option.title }) {
                self?.viewModel.selectedCategory = selectedCategory
            }
        }
        navigationController?.present(optionSheetViewController, animated: true)
    }
    
    private func animateSelection(_ control: UIView) {
        UIView.animate(withDuration: 0.1, animations: {
            control.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                control.transform = .identity
            }
        }
    }
    
    @objc private func beginQuizTapped() {
        startLoadingState()
        viewModel.startQuiz()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.endLoadingState()
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
    
    private func startLoadingState() {
        loadingOverlay.isHidden = false
        activityIndicator.startAnimating()
        beginButton.isEnabled = false
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
            self.beginButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: nil)
    }
    
    private func endLoadingState() {
        loadingOverlay.isHidden = true
        activityIndicator.stopAnimating()
        beginButton.isEnabled = true
        UIView.animate(withDuration: 0.25) {
            self.beginButton.transform = .identity
        }
    }
    
    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func startGame(with quiz: Quiz) {
        let gameViewModel = GameViewModel(quiz: quiz)
        let gameViewController = GameViewController(viewModel: gameViewModel)
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController?.view.layer.add(transition, forKey: nil)
        
        navigationController?.pushViewController(gameViewController, animated: false)
    }
}
