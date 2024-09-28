//
//  QuizConfiguratorViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit
import Combine

class QuizConfiguratorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: QuizConfiguratorViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Styling.standardPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var loadingOverlay: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground.withAlphaComponent(0.7)
        view.isHidden = true
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        indicator.color = .label
        return indicator
    }()
    
    private lazy var difficultySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.selectedSegmentTintColor = .systemBlue
        control.accessibilityLabel = "Difficulty"
        control.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        return configureSegmentedControl(control, with: viewModel.difficulties.map { $0.displayName })
    }()
    
    private lazy var typeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.selectedSegmentTintColor = .systemBlue
        control.accessibilityLabel = "Question Type"
        control.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        return configureSegmentedControl(control, with: viewModel.questionTypes.map { $0.displayName })
    }()
    
    private lazy var questionCountSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = Float(viewModel.questionCountsMin)
        slider.maximumValue = Float(viewModel.questionCountsMax)
        slider.value = Float(viewModel.selectedQuestionCount)
        slider.tintColor = .systemBlue
        slider.accessibilityLabel = "Number of Questions"
        slider.accessibilityHint = "Adjust the number of questions for the quiz"
        slider.addTarget(self, action: #selector(questionCountChanged), for: .valueChanged)
        return slider
    }()
    
    private lazy var questionCountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "Number of Questions: \(viewModel.selectedQuestionCount)"
        return label
    }()
    
    private lazy var categoryButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Select Category"
        button.configuration?.image = UIImage(systemName: "chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(scale: .small))
        button.configuration?.imagePlacement = .trailing
        button.configuration?.imagePadding = 8
        button.configuration?.cornerStyle = .medium
        button.configuration?.baseBackgroundColor = .systemBlue
        button.configuration?.baseForegroundColor = .white
        button.accessibilityLabel = "Category"
        button.accessibilityHint = "Select a category for your quiz"
        button.addTarget(self, action: #selector(categoryTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var beginButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Begin Quiz"
        button.configuration?.image = UIImage(systemName: "play.fill")
        button.configuration?.imagePadding = 8
        button.configuration?.cornerStyle = .large
        button.configuration?.baseBackgroundColor = .systemGreen
        button.configuration?.baseForegroundColor = .white
        button.accessibilityLabel = "Begin Quiz"
        button.accessibilityHint = "Starts the quiz with the selected configuration"
        button.addTarget(self, action: #selector(beginQuizTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    
    init(viewModel: QuizConfiguratorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        bindViewModel()
    }
    
    // MARK: - Setup Methods
    
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
        addCardControlGroup(header: "Difficulty", control: difficultySegmentedControl)
        addCardControlGroup(header: "Question Type", control: typeSegmentedControl)
        addCardControlGroup(header: "Number of Questions", control: setupQuestionCountControl())
        addCardControlGroup(header: "Category", control: categoryButton)
        
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
    
    private func setupQuestionCountControl() -> UIStackView {
        let controlStack = UIStackView()
        controlStack.axis = .vertical
        controlStack.spacing = Styling.standardPadding / 4
        
        questionCountLabel.text = "Number of Questions: \(viewModel.selectedQuestionCount)"
        questionCountLabel.textAlignment = .center
        questionCountLabel.font = UIFont.preferredFont(forTextStyle: .body)
        questionCountLabel.adjustsFontForContentSizeCategory = true
        questionCountLabel.textColor = .label
        
        controlStack.addArrangedSubview(questionCountSlider)
        controlStack.addArrangedSubview(questionCountLabel)
        
        return controlStack
    }
    
    private func setupActivityIndicator() {
        loadingOverlay.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor)
        ])
    }
    
    private func setupLoadingOverlay() {
        view.addSubview(loadingOverlay)
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
    
    private func configureSegmentedControl(_ control: UISegmentedControl, with items: [String]) -> UISegmentedControl {
        control.removeAllSegments()
        items.enumerated().forEach { index, item in
            control.insertSegment(withTitle: item, at: index, animated: false)
        }
        control.selectedSegmentIndex = 0
        control.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.label
        ], for: .normal)
        control.setTitleTextAttributes([
            .font: UIFont.preferredFont(forTextStyle: .body),
            .foregroundColor: UIColor.white
        ], for: .selected)
        return control
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.categoryButton.setTitle(category.displayName, for: .normal)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func difficultyChanged() {
        viewModel.selectedDifficulty = viewModel.difficulties[difficultySegmentedControl.selectedSegmentIndex]
        animateSelection(difficultySegmentedControl)
    }
    
    @objc private func typeChanged() {
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
                self?.start(quiz)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Loading and State Management
    
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
    
    private func start(_ quiz: Quiz) {
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
