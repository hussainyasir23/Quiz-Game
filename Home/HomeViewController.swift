//
//  HomeViewController.swift
//  Quiz Game
//
//  Created by Mohammad on 21/06/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    var highScore = 0
    
    let highScoreLabel = UILabel()
    let newGameButton = UIButton()
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        setViews()
        setConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        highScore = defaults.integer(forKey: "highScore")
        highScoreLabel.text = "High Score: \(highScore)"
    }
    
    func setViews(){

        view.addSubview(highScoreLabel)
        view.addSubview(newGameButton)
    }
    
    func setConstraints(){
        
        view.backgroundColor = #colorLiteral(red: 0.6509803922, green: 0.8901960784, blue: 0.9137254902, alpha: 1)
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.6509803922, green: 0.8901960784, blue: 0.9137254902, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        
        highScoreLabel.text = "High Score: \(highScore)"
        highScoreLabel.font = .boldSystemFont(ofSize: 24)
        highScoreLabel.textAlignment = .center
        highScoreLabel.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        highScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        highScoreLabel.layer.cornerRadius = 10.0
        highScoreLabel.layer.masksToBounds = true
        highScoreLabel.heightAnchor.constraint(equalTo: highScoreLabel.widthAnchor, multiplier: 0.25).isActive = true
        highScoreLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        highScoreLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        highScoreLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -16).isActive = true
        
        newGameButton.titleLabel?.font = .boldSystemFont(ofSize: 24)
        newGameButton.titleLabel?.textAlignment = .center
        newGameButton.setTitleColor(.black, for: .normal)
        newGameButton.setTitle("New Game!", for: .normal)
        newGameButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        newGameButton.translatesAutoresizingMaskIntoConstraints = false
        newGameButton.layer.cornerRadius = 10.0
        newGameButton.heightAnchor.constraint(equalTo: newGameButton.widthAnchor, multiplier: 0.25).isActive = true
        newGameButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        newGameButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: 16).isActive = true
        newGameButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        newGameButton.addTarget(self, action: #selector(newGameTapped), for: .touchUpInside)
    }
    
    @objc func newGameTapped(){
        
        navigationController?.pushViewController(NewGameViewController(), animated: true)
    }
}
