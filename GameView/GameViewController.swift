//
//  GameViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit
import Combine

class GameViewController: UIViewController {
    
    private let viewModel: GameViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private let questionLabel = UILabel()
    private let answerStackView = UIStackView()
    private let scoreLabel = UILabel()
    private let timerLabel = UILabel()
    private let progressView = UIProgressView()
    
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
        viewModel.answerSelected(answer)
    }
    
    private func showGameOverAlert() {
        let alert = UIAlertController(title: "Game Over", message: "Your final score is \(viewModel.score)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }
}
