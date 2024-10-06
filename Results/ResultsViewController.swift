//
//  ResultsViewController.swift
//  Quiz Game
//
//  Created by Yasir on 07/09/24.
//

import UIKit
import SwiftUI

class ResultsViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: ResultsViewModel
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var questionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.backgroundColor = .systemGroupedBackground
        tableView.layer.cornerRadius = 10
        tableView.showsVerticalScrollIndicator = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "QuestionCell")
        return tableView
    }()
    
    private lazy var playAgainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Again", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(playAgainTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share Score", for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        return button
    }()
    
    private var isScoreRevealed: Bool = false
    private var confettiHostingController: UIHostingController<ConfettiView>?
    
    // MARK: - Initialization
    
    init(viewModel: ResultsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        revealScore()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.hidesBackButton = true
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [scoreLabel, messageLabel, questionsTableView, playAgainButton, shareButton].forEach {
            $0.alpha = 0
            contentView.addArrangedSubview($0)
        }
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),
            
            questionsTableView.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            
            playAgainButton.heightAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Configure Data
    
    private func configureData() {
        scoreLabel.text = viewModel.scoreText
        messageLabel.text = viewModel.messageText
    }
    
    // MARK: - Animations
    
    private func revealScore() {
        guard !isScoreRevealed else {
            return
        }
        if viewModel.shouldShowConfetti {
            showConfetti()
        } else {
            animateScoreAppearance()
        }
    }
    
    private func showConfetti() {
        let confettiView = ConfettiView { [weak self] in
            self?.removeConfetti()
            self?.animateScoreAppearance()
        }
        let hostingController = UIHostingController(rootView: confettiView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.confettiHostingController = hostingController
    }
    
    private func removeConfetti() {
        confettiHostingController?.willMove(toParent: nil)
        confettiHostingController?.view.removeFromSuperview()
        confettiHostingController?.removeFromParent()
        confettiHostingController = nil
    }
    
    private func animateScoreAppearance() {
        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseInOut) { [weak self] in
            self?.view.backgroundColor = .secondarySystemGroupedBackground
            self?.scoreLabel.transform = .identity
            self?.scoreLabel.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut) { [weak self] in
                self?.messageLabel.alpha = 1
            } completion: { [weak self] _ in
                self?.isScoreRevealed = true
                UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseInOut) { [weak self] in
                    self?.questionsTableView.alpha = 1
                    self?.playAgainButton.alpha = 1
                    self?.shareButton.alpha = 1
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func playAgainTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func shareTapped() {
        let activityViewController = UIActivityViewController(activityItems: [viewModel.shareMessage], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfQuestions
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
        let userAnswer = viewModel.userAnswer(at: indexPath.row)
        
        var content = cell.defaultContentConfiguration()
        
        content.text = userAnswer.question.question
        content.textProperties.numberOfLines = 2
        content.textProperties.font = UIFont.preferredFont(forTextStyle: .body)
        content.textProperties.adjustsFontForContentSizeCategory = true
        
        content.image = userAnswer.resultImage
        content.imageProperties.tintColor = userAnswer.resultTintColor
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userAnswer = viewModel.userAnswer(at: indexPath.row)
        let questionDetailViewController = QuestionDetailViewController(userAnswer: userAnswer)
        navigationController?.pushViewController(questionDetailViewController, animated: true)
    }
}
