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
    private var cancellables: Set<AnyCancellable> = []
    
    private let highScoreLabel = UILabel()
    private let newGameButton = UIButton()
    
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
        setupConstraints()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadHighScore()
    }
    
    private func setupViews() {
        view.addSubview(highScoreLabel)
        view.addSubview(newGameButton)
        
        view.backgroundColor = #colorLiteral(red: 0.6509803922, green: 0.8901960784, blue: 0.9137254902, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        
        highScoreLabel.font = .boldSystemFont(ofSize: 24)
        highScoreLabel.textAlignment = .center
        highScoreLabel.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        highScoreLabel.layer.cornerRadius = 10.0
        highScoreLabel.layer.masksToBounds = true
        
        newGameButton.titleLabel?.font = .boldSystemFont(ofSize: 24)
        newGameButton.setTitleColor(.black, for: .normal)
        newGameButton.setTitle("New Game!", for: .normal)
        newGameButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        newGameButton.layer.cornerRadius = 10.0
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        newGameButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            highScoreLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32),
            highScoreLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32),
            highScoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -16),
            highScoreLabel.heightAnchor.constraint(equalTo: highScoreLabel.widthAnchor, multiplier: 0.25),
            
            newGameButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32),
            newGameButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32),
            newGameButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 16),
            newGameButton.heightAnchor.constraint(equalTo: newGameButton.widthAnchor, multiplier: 0.25)
        ])
    }
    
    private func bindViewModel() {
        viewModel.$highScore
            .sink { [weak self] highScore in
                self?.highScoreLabel.text = "High Score: \(highScore)"
            }
            .store(in: &cancellables)
    }
    
    @objc private func newGameTapped() {
        let newGameViewController = NewGameViewController()
        navigationController?.pushViewController(newGameViewController, animated: true)
    }
}
