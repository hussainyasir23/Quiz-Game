//
//  ResultViewController.swift
//  Quiz Game
//
//  Created by Mohammad on 25/06/21.
//

import UIKit

class ResultViewController: UIViewController {
    
    var question: Question?{
        didSet{
            for i in 0...question!.results.count-1{
                let temp = PaddedLabel()
                temp.translatesAutoresizingMaskIntoConstraints = false
                temp.font = .systemFont(ofSize: 20)
                temp.backgroundColor = #colorLiteral(red: 0.6509803922, green: 0.8901960784, blue: 0.9137254902, alpha: 1)
                temp.layer.cornerRadius = 10.0
                temp.clipsToBounds = true
                temp.sizeToFit()
                temp.layer.borderWidth = 2
                temp.text = "Question \(i+1):\n\n" + question!.results[i].question + "\n\nCorrect Answer: " + question!.results[i].correct_answer
                temp.numberOfLines = 0
                questionLabel.append(temp)
            }
        }
    }
    
    var questionLabel = [PaddedLabel]()
    var answers = [String]()
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setViews()
        setConstraints()
    }
    
    func setViews(){
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    func setConstraints(){
        
        view.backgroundColor = #colorLiteral(red: 0.4431372549, green: 0.7882352941, blue: 0.8078431373, alpha: 1)
        
        scrollView.contentSize = CGSize(width: 2000, height: 2000)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.isScrollEnabled = true
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -48).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        contentView.isUserInteractionEnabled = true
        
        
        for i in 0...questionLabel.count-1 {
            contentView.addSubview(questionLabel[i])
            if(answers[i] == question?.results[i].correct_answer){
                questionLabel[i].layer.borderColor = CGColor(red: 0, green: 0.5, blue: 0, alpha: 0.87)
            }
            else{
                questionLabel[i].layer.borderColor = CGColor(red: 1, green: 0, blue: 0, alpha: 0.87)
            }
            questionLabel[i].leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0).isActive = true
            questionLabel[i].rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0).isActive = true
            if i==0 {
                questionLabel[i].topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16).isActive = true
            }
            else {
                questionLabel[i].topAnchor.constraint(equalTo: questionLabel[i-1].bottomAnchor, constant: 16).isActive = true
            }
            if i==questionLabel.count-1{
                questionLabel[i].bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32).isActive = true
            }
        }
    }
}

class PaddedLabel: UILabel {
    
    @IBInspectable var topInset: CGFloat = 16.0
    @IBInspectable var bottomInset: CGFloat = 16.0
    @IBInspectable var leftInset: CGFloat = 16.0
    @IBInspectable var rightInset: CGFloat = 16.0
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
