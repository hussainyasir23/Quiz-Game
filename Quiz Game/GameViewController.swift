//
//  GameViewController.swift
//  Quiz Game
//
//  Created by Mohammad on 22/06/21.
//

import UIKit

class GameViewController: UIViewController {
    
    var url = URL(string: "https://opentdb.com/api.php?type=boolean&amount=10")
    let session = URLSession.shared
    var input = Question()
    var currQuesNum = -1
    var currScore = 0
    
    var scoreLabel = UILabel()
    var questionLabel = UILabel()
    let trueButton = UIButton()
    let falseButton = UIButton()
    var progBar = UIProgressView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let task = session.dataTask(with: url!) { data, response, error in
            if error != nil || data == nil {
                print("Client error!")
                return
            }
            do {
                //let json = try JSONSerialization.jsonObject(with: data!, options: [])
                self.input = try! JSONDecoder().decode(Question.self, from: data!)
                //print(self.input.results.count)
                //print(json)
            } catch {
                print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
        
        
        setViews()
        setConstraints()
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateUI), userInfo: nil, repeats: false)
    }
    
    func setViews(){
        
        view.addSubview(scoreLabel)
        view.addSubview(questionLabel)
        view.addSubview(trueButton)
        view.addSubview(falseButton)
        view.addSubview(progBar)
    }
    
    func setConstraints(){
        
        view.backgroundColor = #colorLiteral(red: 0.6509803922, green: 0.8901960784, blue: 0.9137254902, alpha: 1)
        
        scoreLabel.text = "Score: \(currScore)"
        scoreLabel.font = .boldSystemFont(ofSize: 24)
        scoreLabel.textAlignment = .center
        scoreLabel.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.heightAnchor.constraint(equalTo: scoreLabel.widthAnchor, multiplier: 0.2).isActive = true
        scoreLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        scoreLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        
        progBar.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        progBar.translatesAutoresizingMaskIntoConstraints = false
        progBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        progBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        progBar.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 16).isActive = true
        
        questionLabel.text = "Loading your question ..."
        questionLabel.numberOfLines = 0
        questionLabel.font = .systemFont(ofSize: 24)
        questionLabel.textAlignment = .left
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        questionLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        questionLabel.topAnchor.constraint(equalTo: progBar.bottomAnchor, constant: 16).isActive = true
        questionLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        questionLabel.bottomAnchor.constraint(equalTo: trueButton.topAnchor, constant: -16).isActive = true
        
        trueButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        trueButton.titleLabel?.textAlignment = .center
        trueButton.setTitleColor(.black, for: .normal)
        trueButton.setTitle("True", for: .normal)
        trueButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        trueButton.translatesAutoresizingMaskIntoConstraints = false
        trueButton.heightAnchor.constraint(equalTo: trueButton.widthAnchor, multiplier: 0.2).isActive = true
        trueButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        trueButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        trueButton.bottomAnchor.constraint(equalTo: falseButton.topAnchor, constant: -8).isActive = true
        trueButton.addTarget(self, action: #selector(truePressed), for: .touchUpInside)
        
        falseButton.titleLabel?.font = .boldSystemFont(ofSize: 22)
        falseButton.titleLabel?.textAlignment = .center
        falseButton.setTitleColor(.black, for: .normal)
        falseButton.setTitle("False", for: .normal)
        falseButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        falseButton.translatesAutoresizingMaskIntoConstraints = false
        falseButton.heightAnchor.constraint(equalTo: trueButton.widthAnchor, multiplier: 0.2).isActive = true
        falseButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        falseButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        falseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8).isActive = true
        falseButton.addTarget(self, action: #selector(falsePressed), for: .touchUpInside)
    }
    
    @objc func truePressed(){
        if trueButton.currentTitle == input.results[currQuesNum].correct_answer {
            currScore += 1
            trueButton.backgroundColor = .green
        }
        else{
            trueButton.backgroundColor = .red
        }
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: false)
    }
    
    @objc func falsePressed(){
        if falseButton.currentTitle == input.results[currQuesNum].correct_answer {
            currScore += 1
            falseButton.backgroundColor = .green
        }
        else{
            falseButton.backgroundColor = .red
        }
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateUI), userInfo: nil, repeats: false)
    }
    
    @objc func updateUI(){
        currQuesNum += 1
        trueButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        falseButton.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        if(currQuesNum < input.results.count){
            scoreLabel.text = "Score: \(currScore)"
            progBar.setProgress(Float(currQuesNum + 1)/Float(input.results.count), animated: true)
            questionLabel.text = input.results[currQuesNum].question
            //print("Q\(currQuesNum):\t\(input.results[currQuesNum].question)")
            
        }
        else if currQuesNum >= input.results.count{
            scoreLabel.isHidden = true
            progBar.isHidden = true
            trueButton.isHidden = true
            falseButton.isHidden = true
            if input.response_code != 1{
                questionLabel.text = "Score: \(currScore)"
                questionLabel.textAlignment = .center
                questionLabel.font = .boldSystemFont(ofSize: 32)
            }
            else{
                questionLabel.text = "Unable to fetch Questions\nPlease Try Again!"
                questionLabel.textAlignment = .center
            }
        }
    }
}
