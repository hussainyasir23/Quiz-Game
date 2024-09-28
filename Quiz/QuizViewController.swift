//
//  QuizViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit
import Combine
import AVFoundation
import AudioToolbox

class QuizViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: QuizViewModel
    private var cancellables = Set<AnyCancellable>()
    private var audioPlayer: AVAudioPlayer?
    
    private enum GameEffect {
        case correct
        case incorrect
        case gameOver
        case timerTick
    }
    
    // MARK: - UI Elements
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var answerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .systemGray5
        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()
    
    // MARK: - Initializers
    
    init(viewModel: QuizViewModel) {
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
        setupAudio()
        setupNavigation()
        bindViewModel()
        viewModel.startGame()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        [questionLabel, answerStackView, scoreLabel, timerLabel, progressView].forEach {
            view.addSubview($0)
        }
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            questionLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            answerStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            answerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            answerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupAudio() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.ambient, mode: .default)
            try session.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupNavigation() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(exitGameTapped)
        )
    }
    
    @objc private func exitGameTapped() {
        let alert = UIAlertController(
            title: "Exit Game",
            message: "Are you sure you want to exit? Your progress will be lost.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) {
            [weak self] _ in
            self?.play(.gameOver)
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - ViewModel Binding
    
    private func bindViewModel() {
        
        viewModel.$currentQuestion
            .receive(on: DispatchQueue.main)
            .sink { [weak self] question in
                self?.updateUI(with: question)
            }
            .store(in: &cancellables)
        
        viewModel.$score
            .receive(on: DispatchQueue.main)
            .map { "Score: \($0)" }
            .assign(to: \.text, on: scoreLabel)
            .store(in: &cancellables)
        
        viewModel.$timeRemaining
            .receive(on: DispatchQueue.main)
            .sink { [weak self] time in
                self?.timerLabel.text = "Time: \(time)s"
            }
            .store(in: &cancellables)
        
        viewModel.$isGameOver
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isGameOver in
                if isGameOver {
                    self?.play(.gameOver)
                    self?.showGameOverAlert()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$shouldPlayTimerSound
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldPlay in
                if shouldPlay {
                    self?.play(.timerTick)
                    self?.timerLabel.textColor = .systemRed
                } else {
                    self?.timerLabel.textColor = .secondaryLabel
                }
            }
            .store(in: &cancellables)
        
        viewModel.$currentQuestionIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] index in
                guard let self = self else { return }
                let progress = Float(index) / Float(self.viewModel.totalQuestions)
                self.progressView.setProgress(progress, animated: true)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Updates
    
    private func updateUI(with question: Question?) {
        guard let question = question else { return }
        
        questionLabel.text = question.question
        
        answerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        question.allAnswers.forEach { answer in
            let button = createAnswerButton(with: answer)
            answerStackView.addArrangedSubview(button)
        }
        
        updateAnswerButtonsState(enabled: true)
    }
    
    private func createAnswerButton(with title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.backgroundColor = .secondarySystemGroupedBackground
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .body)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addTarget(self, action: #selector(answerSelected(_:)), for: .touchUpInside)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 50).isActive = true
        return button
    }
    
    @objc private func answerSelected(_ sender: UIButton) {
        guard let answer = sender.titleLabel?.text else { return }
        
        let isCorrect = answer == viewModel.currentQuestion?.correctAnswer
        play(isCorrect ? .correct : .incorrect)
        
        updateAnswerButtonsState(enabled: false)
        highlightAnswers(selectedButton: sender, isCorrect: isCorrect)
        
        viewModel.answerSelected(answer)
    }
    
    private func updateAnswerButtonsState(enabled: Bool) {
        answerStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                button.isEnabled = enabled
            }
        }
    }
    
    private func highlightAnswers(selectedButton: UIButton, isCorrect: Bool) {
        let correctAnswer = viewModel.currentQuestion?.correctAnswer
        UIView.animate(withDuration: 0.3, animations: {
            selectedButton.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            selectedButton.backgroundColor = isCorrect ? .systemGreen : .systemRed
            if !isCorrect {
                self.answerStackView.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton,
                       button.titleLabel?.text == correctAnswer {
                        button.backgroundColor = .systemGreen
                        button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                    }
                }
            }
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.answerStackView.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton {
                        button.transform = .identity
                        button.backgroundColor = .secondarySystemGroupedBackground
                    }
                }
            }
        }
    }
    
    private func play(_ gameEffect: GameEffect) {
        switch gameEffect {
        case .correct:
            FeedbackManager.triggerNotificationFeedback(of: .success)
            SoundEffectManager.shared.playSound(.correct)
        case .incorrect:
            FeedbackManager.triggerNotificationFeedback(of: .error)
            SoundEffectManager.shared.playSound(.incorrect)
        case .gameOver:
            FeedbackManager.triggerNotificationFeedback(of: .warning)
        case .timerTick:
            FeedbackManager.triggerImpactFeedback(of: .light)
        }
    }
    
    private func showGameOverAlert() {
        let resultsVC = ResultsViewController(
            score: viewModel.score,
            totalQuestions: viewModel.totalQuestions,
            totalTime: viewModel.totalTime
        )
        navigationController?.pushViewController(resultsVC, animated: true)
    }
}
