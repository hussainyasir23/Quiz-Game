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
        bindViewModel()
        viewModel.startTimer()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        [questionLabel, answerStackView, scoreLabel, timerLabel, progressView].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.font = .systemFont(ofSize: 20, weight: .bold)
        
        answerStackView.axis = .vertical
        answerStackView.spacing = 10
        answerStackView.distribution = .fillEqually
        
        scoreLabel.textAlignment = .left
        timerLabel.textAlignment = .right
        
        NSLayoutConstraint.activate([
            questionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            questionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            questionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            answerStackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 20),
            answerStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            answerStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        view.backgroundColor = Styling.backgroundColor
        
        questionLabel.font = Styling.titleFont
        questionLabel.textColor = .darkGray
        
        scoreLabel.font = Styling.bodyFont
        scoreLabel.textColor = Styling.primaryColor
        
        timerLabel.font = Styling.bodyFont
        timerLabel.textColor = Styling.secondaryColor
        
        progressView.progressTintColor = Styling.primaryColor
        progressView.trackTintColor = Styling.secondaryColor.withAlphaComponent(0.3)
        
        answerStackView.arrangedSubviews.forEach { view in
            if let button = view as? UIButton {
                Styling.styleButton(button)
            }
        }
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
            .map { "Time: \($0)s" }
            .assign(to: \.text, on: timerLabel)
            .store(in: &cancellables)
        
        viewModel.$isGameOver
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isGameOver in
                if isGameOver {
                    self?.showGameOverAlert()
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
            button.titleLabel?.font = .systemFont(ofSize: 18)
            button.backgroundColor = .systemGray5
            button.layer.cornerRadius = 10
            button.addTarget(self, action: #selector(answerSelected(_:)), for: .touchUpInside)
            answerStackView.addArrangedSubview(button)
        }
    }
    
    @objc private func answerSelected(_ sender: UIButton) {
        guard let answer = sender.titleLabel?.text else { return }
        
        let correct = answer == viewModel.currentQuestion?.correctAnswer
        playSound(correct: correct)
        
        UIView.animate(withDuration: 0.3, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            sender.backgroundColor = correct ? .green : .red
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                sender.transform = .identity
                sender.backgroundColor = .systemGray5
            }
        }
        
        viewModel.answerSelected(answer)
    }
    
    private func showGameOverAlert() {
        let resultsVC = ResultsViewController(
            score: viewModel.score,
            totalQuestions: viewModel.totalQuestions,
            totalTime: viewModel.totalTime
        )
        navigationController?.pushViewController(resultsVC, animated: true)
    }
    
    private func setupAudio() {
        guard let correctSoundURL = Bundle.main.url(forResource: "correct", withExtension: "mp3"),
              let incorrectSoundURL = Bundle.main.url(forResource: "incorrect", withExtension: "mp3") else {
            print("Sound files not found")
            return
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    private func playSound(correct: Bool) {
        let soundName = correct ? "correct" : "incorrect"
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: "mp3") else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound: \(error)")
        }
    }
}
