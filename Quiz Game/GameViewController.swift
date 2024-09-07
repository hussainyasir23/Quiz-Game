//
//  GameViewController.swift
//  Quiz Game
//
//  Created by Mohammad on 22/06/21.
//

import UIKit

class GameViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    
    var url = URL(string: "https://opentdb.com/api.php?type=boolean&amount=10")
    let session = URLSession.shared
    var input = Question()
    var currQuesNum = -1
    var currScore = 0
    var answers = [String]()
    
    let gameView = UIView()
    
    var currScoreLabel = UILabel()
    var questionLabel = UILabel()
    let trueButton = UIButton()
    let falseButton = UIButton()
    var progBar = UIProgressView()
    
    let postGame = UIView()
    
    let scoreLabel = UILabel()
    let checkAnswer = UIButton()
    let homeButton = UIButton()
    
    weak var dismissDelegate: DismissDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        parse(url: url!)
        
        setViews()
        setConstraints()
    }
    
    func setViews(){
        
        view.addSubview(gameView)
        
        gameView.addSubview(currScoreLabel)
        gameView.addSubview(questionLabel)
        gameView.addSubview(progBar)
        gameView.addSubview(trueButton)
        gameView.addSubview(falseButton)
        
        postGame.addSubview(scoreLabel)
        postGame.addSubview(checkAnswer)
        postGame.addSubview(homeButton)
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.6509803922, green: 0.8901960784, blue: 0.9137254902, alpha: 1)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setConstraints(){
        
        view.backgroundColor = #colorLiteral(red: 0.6509803922, green: 0.8901960784, blue: 0.9137254902, alpha: 1)
        
        gameView.translatesAutoresizingMaskIntoConstraints = false
        gameView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        gameView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        gameView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        gameView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        currScoreLabel.text = "Score: \(currScore)"
        currScoreLabel.font = .boldSystemFont(ofSize: 24)
        currScoreLabel.textAlignment = .center
        currScoreLabel.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        currScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        currScoreLabel.layer.cornerRadius = 10.0
        currScoreLabel.layer.masksToBounds = true
        currScoreLabel.heightAnchor.constraint(equalTo: currScoreLabel.widthAnchor, multiplier: 0.2).isActive = true
        currScoreLabel.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 32).isActive = true
        currScoreLabel.topAnchor.constraint(equalTo: gameView.topAnchor, constant: 8).isActive = true
        currScoreLabel.rightAnchor.constraint(equalTo: gameView.rightAnchor, constant: -32).isActive = true
        
        progBar.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        progBar.translatesAutoresizingMaskIntoConstraints = false
        progBar.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 32).isActive = true
        progBar.rightAnchor.constraint(equalTo: gameView.rightAnchor, constant: -32).isActive = true
        progBar.topAnchor.constraint(equalTo: currScoreLabel.bottomAnchor, constant: 16).isActive = true
        
        questionLabel.text = "Loading your questions ..."
        questionLabel.numberOfLines = 0
        questionLabel.font = .boldSystemFont(ofSize: 24)
        questionLabel.textAlignment = .center
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 32).isActive = true
        questionLabel.topAnchor.constraint(equalTo: progBar.bottomAnchor, constant: 16).isActive = true
        questionLabel.rightAnchor.constraint(equalTo: gameView.rightAnchor, constant: -32).isActive = true
        questionLabel.bottomAnchor.constraint(equalTo: trueButton.topAnchor, constant: -16).isActive = true
        
        trueButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        trueButton.titleLabel?.textAlignment = .center
        trueButton.setTitleColor(.black, for: .normal)
        trueButton.setTitle("True", for: .normal)
        trueButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        trueButton.translatesAutoresizingMaskIntoConstraints = false
        trueButton.layer.cornerRadius = 10.0
        trueButton.heightAnchor.constraint(equalTo: trueButton.widthAnchor, multiplier: 0.2).isActive = true
        trueButton.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 32).isActive = true
        trueButton.rightAnchor.constraint(equalTo: gameView.rightAnchor, constant: -32).isActive = true
        trueButton.bottomAnchor.constraint(equalTo: falseButton.topAnchor, constant: -8).isActive = true
        trueButton.addTarget(self, action: #selector(answerPressed), for: .touchUpInside)
        
        falseButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        falseButton.titleLabel?.textAlignment = .center
        falseButton.setTitleColor(.black, for: .normal)
        falseButton.setTitle("False", for: .normal)
        falseButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        falseButton.translatesAutoresizingMaskIntoConstraints = false
        falseButton.layer.cornerRadius = 10.0
        falseButton.heightAnchor.constraint(equalTo: trueButton.widthAnchor, multiplier: 0.2).isActive = true
        falseButton.leftAnchor.constraint(equalTo: gameView.leftAnchor, constant: 32).isActive = true
        falseButton.rightAnchor.constraint(equalTo: gameView.rightAnchor, constant: -32).isActive = true
        falseButton.bottomAnchor.constraint(equalTo: gameView.bottomAnchor, constant: -8).isActive = true
        falseButton.addTarget(self, action: #selector(answerPressed), for: .touchUpInside)
        
        currScoreLabel.isHidden = true
        progBar.isHidden = true
        trueButton.isHidden = true
        falseButton.isHidden = true
    }
    
    
    func setPostGameConstraints(){
        
        postGame.translatesAutoresizingMaskIntoConstraints = false
        postGame.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        postGame.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        postGame.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        postGame.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        defaults.set(currScore, forKey: "highScore")
        
        scoreLabel.text = "Score: \(currScore)"
        scoreLabel.font = .boldSystemFont(ofSize: 32)
        scoreLabel.textAlignment = .center
        //scoreLabel.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.layer.cornerRadius = 10.0
        scoreLabel.layer.masksToBounds = true
        scoreLabel.heightAnchor.constraint(equalTo: scoreLabel.widthAnchor, multiplier: 0.4).isActive = true
        scoreLabel.leftAnchor.constraint(equalTo: postGame.leftAnchor, constant: 32).isActive = true
        scoreLabel.bottomAnchor.constraint(equalTo: postGame.centerYAnchor, constant: 16).isActive = true
        scoreLabel.rightAnchor.constraint(equalTo: postGame.rightAnchor, constant: -32).isActive = true
        
        checkAnswer.titleLabel?.font = .boldSystemFont(ofSize: 22)
        checkAnswer.titleLabel?.textAlignment = .center
        checkAnswer.setTitleColor(.black, for: .normal)
        checkAnswer.setTitle("View Quiz Results", for: .normal)
        checkAnswer.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        checkAnswer.translatesAutoresizingMaskIntoConstraints = false
        checkAnswer.layer.cornerRadius = 10.0
        checkAnswer.heightAnchor.constraint(equalTo: checkAnswer.widthAnchor, multiplier: 0.2).isActive = true
        checkAnswer.leftAnchor.constraint(equalTo: postGame.leftAnchor, constant: 32).isActive = true
        checkAnswer.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16).isActive = true
        checkAnswer.rightAnchor.constraint(equalTo: postGame.rightAnchor, constant: -32).isActive = true
        checkAnswer.addTarget(self, action: #selector(ResultPressed), for: .touchUpInside)
        
        homeButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        homeButton.titleLabel?.textAlignment = .center
        homeButton.setTitleColor(.black, for: .normal)
        homeButton.setTitle("Home", for: .normal)
        homeButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        homeButton.layer.cornerRadius = 10.0
        homeButton.heightAnchor.constraint(equalTo: homeButton.widthAnchor, multiplier: 0.2).isActive = true
        homeButton.leftAnchor.constraint(equalTo: postGame.leftAnchor, constant: 32).isActive = true
        homeButton.topAnchor.constraint(equalTo: checkAnswer.bottomAnchor, constant: 16).isActive = true
        homeButton.rightAnchor.constraint(equalTo: postGame.rightAnchor, constant: -32).isActive = true
        homeButton.addTarget(self, action: #selector(HomePressed), for: .touchUpInside)
    }
    
    func parse (url: URL){
        URLSession.shared.dataTask(with: url) { (data, res, error) in
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            do {
                self.input = try JSONDecoder().decode(Question.self, from: data!)
                DispatchQueue.main.async {
                    self.startGame()
                }
            } catch {
                print("didnt work")
            }
        }.resume()
    }
    
    @objc func answerPressed(sender: UIButton!){
        answers.append(sender.currentTitle!)
        if sender.currentTitle == input.results[currQuesNum].correct_answer {
            currScore += 1
            sender.backgroundColor = .green
        }
        else{
            sender.backgroundColor = .red
        }
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: false)
    }
    
    @objc func startGame(){
        if(input.response_code != 0){
            questionLabel.text = "Unable to fetch questions.\nPlease try after some time."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.dismiss(animated: true){
                    self.dismissDelegate?.didDismiss()
                }
            }
        }
        else{
            currScoreLabel.isHidden = false
            progBar.isHidden = false
            trueButton.isHidden = false
            falseButton.isHidden = false
            questionLabel.textAlignment = .left
            questionLabel.font = .systemFont(ofSize: 24)
            updateUI()
        }
    }
    
    @objc func updateUI(){
        currQuesNum += 1
        trueButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        falseButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        if(currQuesNum < input.results.count){
            currScoreLabel.text = "Score: \(currScore)"
            progBar.setProgress(Float(currQuesNum + 1)/Float(input.results.count), animated: true)
            questionLabel.text = input.results[currQuesNum].question
            //print(input.results[currQuesNum])
            //print("Q\(currQuesNum):\t\(input.results[currQuesNum].question)")
        }
        else if currQuesNum >= input.results.count{
            gameView.removeFromSuperview()
            view.addSubview(postGame)
            setPostGameConstraints()
        }
    }
    
    @objc func ResultPressed(){
        let resultView = ResultViewController()
        resultView.question = input
        resultView.answers = self.answers
        navigationController?.pushViewController(resultView, animated: true)
        
    }
    
    @objc func HomePressed(){
        self.dismiss(animated: true,completion: {
            self.dismissDelegate?.didDismiss()
        })
    }
}
