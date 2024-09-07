//
//  ResultsViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit

class ResultsViewController: UIViewController {
    
    private let scoreLabel = UILabel()
    private let accuracyLabel = UILabel()
    private let timeLabel = UILabel()
    private let highScoreLabel = UILabel()
    private let playAgainButton = UIButton(type: .system)
    
    private let score: Int
    private let totalQuestions: Int
    private let totalTime: TimeInterval
    
    init(score: Int, totalQuestions: Int, totalTime: TimeInterval) {
        self.score = score
        self.totalQuestions = totalQuestions
        self.totalTime = totalTime
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkHighScore()
    }
    
    private func setupUI() {
        view.backgroundColor = Styling.primaryBackgroundColor
        
        let stackView = UIStackView(arrangedSubviews: [scoreLabel, accuracyLabel, timeLabel, highScoreLabel, playAgainButton])
        stackView.axis = .vertical
        stackView.spacing = Styling.standardPadding
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Styling.standardPadding),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Styling.standardPadding)
        ])
        
        setupLabels()
        setupPlayAgainButton()
    }
    
    private func setupLabels() {
        scoreLabel.text = "Score: \(score)/\(totalQuestions)"
        scoreLabel.textAlignment = .center
        
        let accuracy = Double(score) / Double(totalQuestions) * 100
        accuracyLabel.text = String(format: "Accuracy: %.1f%%", accuracy)
        accuracyLabel.textAlignment = .center
        
        timeLabel.text = String(format: "Total Time: %.1f seconds", totalTime)
        timeLabel.textAlignment = .center
        
        highScoreLabel.textAlignment = .center
        
        [scoreLabel, accuracyLabel, timeLabel, highScoreLabel].forEach { Styling.styleLabel($0) }
        
        scoreLabel.font = Styling.titleFont
    }
    
    private func setupPlayAgainButton() {
        playAgainButton.setTitle("Play Again", for: .normal)
        playAgainButton.addTarget(self, action: #selector(playAgainTapped), for: .touchUpInside)
        Styling.styleButton(playAgainButton, isTitle: true)
    }
    
    @objc private func playAgainTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func checkHighScore() {
        let highScore = HighScoreManager.shared.getHighScore()
        if score > highScore {
            HighScoreManager.shared.setHighScore(score)
            highScoreLabel.text = "New High Score: \(score)!"
        } else {
            highScoreLabel.text = "High Score: \(highScore)"
        }
    }
}
