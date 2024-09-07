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
        view.backgroundColor = .systemBackground
        
        let stackView = UIStackView(arrangedSubviews: [scoreLabel, accuracyLabel, timeLabel, highScoreLabel, playAgainButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        scoreLabel.text = "Score: \(score)/\(totalQuestions)"
        scoreLabel.font = UIFont.boldSystemFont(ofSize: 24)
        scoreLabel.textAlignment = .center
        
        let accuracy = Double(score) / Double(totalQuestions) * 100
        accuracyLabel.text = String(format: "Accuracy: %.1f%%", accuracy)
        accuracyLabel.font = UIFont.systemFont(ofSize: 18)
        accuracyLabel.textAlignment = .center
        
        timeLabel.text = String(format: "Total Time: %.1f seconds", totalTime)
        timeLabel.font = UIFont.systemFont(ofSize: 18)
        timeLabel.textAlignment = .center
        
        highScoreLabel.font = UIFont.systemFont(ofSize: 18)
        highScoreLabel.textAlignment = .center
        
        playAgainButton.setTitle("Play Again", for: .normal)
        playAgainButton.addTarget(self, action: #selector(playAgainTapped), for: .touchUpInside)
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

import UIKit

struct Styling {
    static let primaryColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0)
    static let secondaryColor = UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
    static let backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
    
    static let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
    static let bodyFont = UIFont.systemFont(ofSize: 18, weight: .regular)
    
    static func styleButton(_ button: UIButton) {
        button.backgroundColor = primaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = bodyFont
    }
    
    static func styleLabel(_ label: UILabel) {
        label.textColor = .darkGray
        label.font = bodyFont
    }
}
