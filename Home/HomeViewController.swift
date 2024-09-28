//
//  HomeViewController.swift
//  Quiz Game
//
//  Created by Mohammad on 21/06/21.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Elements
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "quiz-logo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var startQuizButton: UIButton = {
        let button = UIButton(configuration: .filled())
        button.configuration?.title = "Start Quiz"
        button.configuration?.image = UIImage(systemName: "play.fill")
        button.configuration?.imagePadding = 8
        button.configuration?.cornerStyle = .large
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(startQuizTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var highScoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityLabel = "High Score Label"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var settingsButton: UIButton = {
        let button = UIButton(configuration: .plain())
        button.configuration?.image = UIImage(systemName: "gear")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImageView, startQuizButton, highScoreLabel])
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initializers
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadHighScore()
    }
    
    // MARK: - UI Setup
    
    private func setupViews() {
        configureViewAppearance()
        addSubviews()
        setupConstraints()
    }
    
    private func configureViewAppearance() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func addSubviews() {
        view.addSubview(stackView)
        view.addSubview(settingsButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoImageView.heightAnchor.constraint(equalToConstant: 120),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            
            startQuizButton.heightAnchor.constraint(equalToConstant: 50),
            startQuizButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.7),
            
            settingsButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            settingsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        viewModel.$highScore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] highScore in
                self?.highScoreLabel.text = "High Score: \(highScore)"
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Button Actions
    
    @objc private func startQuizTapped() {
        let quizConfiguratorViewModel = viewModel.createQuizConfiguratorViewModel()
        let quizConfiguratorViewController = QuizConfiguratorViewController(viewModel: quizConfiguratorViewModel)
        
        FeedbackManager.triggerImpactFeedback(of: .light)
        SoundEffectManager.shared.playSound(.select)
        navigationController?.pushViewController(quizConfiguratorViewController, animated: true)
    }
    
    @objc private func settingsTapped() {
        let settingsViewController = SettingsViewController()
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
}
