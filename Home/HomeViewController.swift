//
//  HomeViewController.swift
//  Quiz Game
//
//  Created by Mohammad on 21/06/21.
//

import UIKit
import Combine

class HomeViewController: UIViewController {
    
    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let highScoreLabel = UILabel()
    private let newGameButton = UIButton(type: .system)
    
    init(viewModel: HomeViewModel = HomeViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadHighScore()
    }
    
    private func setupViews() {
        view.backgroundColor = Styling.primaryBackgroundColor
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        [highScoreLabel, newGameButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupHighScoreLabel()
        setupNewGameButton()
        setupConstraints()
    }
    
    private func setupHighScoreLabel() {
        highScoreLabel.font = Styling.titleFont
        highScoreLabel.textAlignment = .center
        highScoreLabel.backgroundColor = Styling.primaryColor
        highScoreLabel.textColor = Styling.primaryTextColor
        highScoreLabel.layer.cornerRadius = Styling.cornerRadius
        highScoreLabel.layer.masksToBounds = true
    }
    
    private func setupNewGameButton() {
        newGameButton.titleLabel?.font = Styling.titleFont
        newGameButton.setTitleColor(Styling.primaryTextColor, for: .normal)
        newGameButton.setTitle("New Game!", for: .normal)
        Styling.styleButton(newGameButton, isTitle: true)
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            highScoreLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Styling.standardPadding),
            highScoreLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -Styling.standardPadding),
            highScoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -Styling.standardPadding / 2),
            highScoreLabel.heightAnchor.constraint(equalTo: highScoreLabel.widthAnchor, multiplier: 0.25),
            
            newGameButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Styling.standardPadding),
            newGameButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -Styling.standardPadding),
            newGameButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: Styling.standardPadding / 2),
            newGameButton.heightAnchor.constraint(equalTo: newGameButton.widthAnchor, multiplier: 0.25)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$highScore
            .receive(on: DispatchQueue.main)
            .sink { [weak self] highScore in
                self?.highScoreLabel.text = "High Score: \(highScore)"
            }
            .store(in: &cancellables)
    }
    
    @objc private func newGameTapped() {
        let newGameViewModel = viewModel.createNewGameViewModel()
        let newGameViewController = NewGameViewController(viewModel: newGameViewModel)
        navigationController?.pushViewController(newGameViewController, animated: true)
    }
}
