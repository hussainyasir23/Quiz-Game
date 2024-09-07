//
//  GameViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit
import Combine
import AVFoundation

class GameViewController: UIViewController {
    
    private let viewModel: GameViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private let questionLabel = UILabel()
    private let answerStackView = UIStackView()
    private let scoreLabel = UILabel()
    private let timerLabel = UILabel()
    private let progressView = UIProgressView()
    
    private var audioPlayer: AVAudioPlayer?
    private enum SystemSoundName: String {
        case correct = "/System/Library/Audio/UISounds/message_received.caf"
        case incorrect = "/System/Library/Audio/UISounds/low_power.caf"
        case gameOver = "/System/Library/Audio/UISounds/alarm.caf"
        case timerTick = "/System/Library/Audio/UISounds/short_low_high.caf"
    }
    
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAudio()
        setupNavigation()
        bindViewModel()
        viewModel.startGame()
    }
    
    private func setupUI() {
        view.backgroundColor = Styling.primaryBackgroundColor
        
        [questionLabel, answerStackView, scoreLabel, timerLabel, progressView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupQuestionLabel()
        setupAnswerStackView()
        setupScoreLabel()
        setupTimerLabel()
        setupProgressView()
        setupConstraints()
    }
    
    private func setupQuestionLabel() {
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .left
        questionLabel.font = Styling.titleFont
        questionLabel.textColor = Styling.primaryTextColor
    }
    
    private func setupAnswerStackView() {
        answerStackView.axis = .vertical
        answerStackView.spacing = Styling.standardPadding / 1.5
        answerStackView.distribution = .fillEqually
    }
    
    private func setupScoreLabel() {
        scoreLabel.textAlignment = .left
        scoreLabel.font = Styling.bodyFont
        scoreLabel.textColor = Styling.primaryTextColor
    }
    
    private func setupTimerLabel() {
        timerLabel.textAlignment = .right
        timerLabel.font = Styling.bodyFont
        timerLabel.textColor = Styling.primaryTextColor
    }
    
    private func setupProgressView() {
        progressView.progressTintColor = Styling.primaryColor
        progressView.trackTintColor = Styling.primaryTextColor.withAlphaComponent(0.25)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Styling.standardPadding),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styling.standardPadding),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styling.standardPadding),
            
            answerStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: Styling.standardPadding),
            answerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styling.standardPadding),
            answerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styling.standardPadding),
            
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styling.standardPadding),
            scoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Styling.standardPadding),
            
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styling.standardPadding),
            timerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Styling.standardPadding),
            
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func setupNavigation() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(exitGameTapped))
        navigationController?.navigationBar.tintColor = Styling.primaryTextColor
    }
    
    @objc private func exitGameTapped() {
        
        let alert = UIAlertController(title: "Exit Game", message: "Are you sure you want to exit? Your progress will be lost.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive, handler: { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
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
                    self?.playSound(.gameOver)
                    self?.showGameOverAlert()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$shouldPlayTimerSound
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldPlay in
                if shouldPlay {
                    self?.playSound(.timerTick)
                    self?.timerLabel.textColor = .red
                } else {
                    self?.timerLabel.textColor = Styling.primaryTextColor
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
    
    
    private func updateUI(with question: Question?) {
        guard let question = question else { return }
        
        questionLabel.text = question.question
        
        answerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let answers = question.allAnswers
        answers.forEach { answer in
            let button = UIButton(type: .system)
            button.setTitle(answer, for: .normal)
            button.addTarget(self, action: #selector(answerSelected(_:)), for: .touchUpInside)
            Styling.styleButton(button)
            button.heightAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.15).isActive = true
            answerStackView.addArrangedSubview(button)
        }
        
        updateAnswerButtonsState(enabled: true)
    }
    
    @objc private func answerSelected(_ sender: UIButton) {
        guard let answer = sender.titleLabel?.text else { return }
        
        let isCorrect = answer == viewModel.currentQuestion?.correctAnswer
        playSound(isCorrect ? .correct : .incorrect)
        
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
            selectedButton.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            selectedButton.backgroundColor = isCorrect ? .green : .red
            if !isCorrect {
                self.answerStackView.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton,
                       button.titleLabel?.text == correctAnswer {
                        button.backgroundColor = .green
                        button.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }
                }
            }
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.answerStackView.arrangedSubviews.forEach { view in
                    if let button = view as? UIButton {
                        button.transform = .identity
                        button.backgroundColor = Styling.primaryColor
                    }
                }
            }
        }
    }
    
    private func playSound(_ sound: SystemSoundName) {
        guard let url = URL(string: sound.rawValue) else {
            print("Invalid sound file path")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
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
