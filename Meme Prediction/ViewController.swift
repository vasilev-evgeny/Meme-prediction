//
//  ViewController.swift
//  Meme Prediction
//
//  Created by Евгений Васильев on 14.07.2025.
//

import UIKit

class ViewController: UIViewController {

    enum Constants {
        
    }
    
    var memeMamager  = MemeManager()
    var memes : [Meme] = []
    var memeImageUrl = ""
    
    //MARK: - Create UI
    
    let memeRequestTextfield : UITextField = {
        let field = UITextField()
        field.placeholder = "Введите ваш запрос"
        field.textColor = .black
        field.backgroundColor = .systemGray5
        field.layer.cornerRadius = 10
        let lupaView = UIImageView()
        lupaView.image = UIImage(named: "icons8")
        field.leftViewMode = .always
        field.leftView = lupaView
        return field
    }()
    
    let getMemeRequestButton : UIButton = {
        let button = UIButton()
        button.setTitle("Получить предсказание", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.titleLabel?.textColor = .black
        button.backgroundColor = .magenta
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(getMemeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let memeImageView : UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .black
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 10
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        return view
    }()
    
    let likeButton : UIButton = {
        let button = UIButton()
        button.setTitle("👍🏻", for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 5
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let dislikeButton : UIButton = {
        let button = UIButton()
        button.setTitle("👎🏻", for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 5
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(dislikeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    let reactionButtonsStackView : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 10
        view.distribution = .fillEqually
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 20)
        return view
    }()
    
    let likeEmojiView : UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "likeIcon")
        view.isHidden = true
        return view
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(memeRequestTextfield)
        view.addSubview(getMemeRequestButton)
        view.addSubview(memeImageView)
        view.addSubview(reactionButtonsStackView)
        reactionButtonsStackView.addArrangedSubview(dislikeButton)
        reactionButtonsStackView.addArrangedSubview(likeButton)
        view.addSubview(likeEmojiView)
    }
    
    //MARK: - Action Func

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { [weak self] in
                self?.memeImageView.image = UIImage(data: data)
            }
        }
    }

    @objc func getMemeButtonTapped(sender: UIButton) {
        likeButton.isUserInteractionEnabled = true
        dislikeButton.isUserInteractionEnabled = true
        buttonAnimate(sender: sender)
        memeMamager.getMeme { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let memes) :
                    self?.memes = memes
                    self?.memeImageUrl = memes.randomElement()!.url
                    self?.downloadImage(from: URL(string: self!.memeImageUrl)!)
                    UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                        self?.reactionButtonsStackView.alpha = 1
                        self?.reactionButtonsStackView.transform = .identity})
                case.failure(let error) :
                    print(error.localizedDescription)
                }
            }
        }
    }
    
//    @objc func dislikeButtonTapped(sender: UIButton) {
//        print("Мемов осталось в массиве \(memes.count)")
//        buttonAnimate(sender: sender)
//        let randomMem = memes.randomElement()
//        let url = randomMem!.url
//        let index = memes.firstIndex(where: { $0.url == randomMem!.url})
//        memes.remove(at: index!)
//        downloadImage(from: URL(string: url)!)
//    }
    
    @objc func dislikeButtonTapped(sender: UIButton) {
        buttonAnimate(sender: sender)
        guard !memes.isEmpty else {
            print("Мемы закончились!")
            return
        }
            UIView.transition(
            with: memeImageView,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                self.memeImageView.alpha = 0
            },
            completion: { _ in
                let randomMem = self.memes.randomElement()!
                let url = randomMem.url
                if let index = self.memes.firstIndex(where: { $0.url == randomMem.url }) {
                    self.memes.remove(at: index)
                }
                self.downloadImage(from: URL(string: url)!)
                UIView.transition(
                    with: self.memeImageView,
                    duration: 0.3,
                    options: .transitionCrossDissolve,
                    animations: {
                        self.memeImageView.alpha = 1
                    }
                )
                print("Мемов осталось в массиве \(self.memes.count)")
            }
        )
    }
    
    @objc func likeButtonTapped(sender: UIButton) {
        buttonAnimate(sender: sender)
        likeEmojiView.layer.opacity = 1
        likeEmojiView.isHidden = false
        likeAnimation()
    }
    
    @objc func likeAnimation() {
        UIView.animate(withDuration: 0.5) {
            self.memeImageView.layer.shadowColor = UIColor.green.cgColor
            self.memeImageView.layer.shadowOpacity = 0.5
            self.memeImageView.layer.shadowRadius = 45
            self.likeEmojiView.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        } completion: { done in
            if done {
                UIView.animate(withDuration: 0.5) {
                    self.memeImageView.layer.shadowColor = UIColor.green.cgColor
                    self.memeImageView.layer.shadowOpacity = 1
                    self.memeImageView.layer.shadowRadius = 70
                    self.likeEmojiView.transform = CGAffineTransform(scaleX: 2, y: 2)
                } completion: { done in
                    if done {
                        self.memeImageView.layer.shadowColor = UIColor.clear.cgColor
                        self.memeImageView.layer.shadowOpacity = 0
                        self.memeImageView.layer.shadowRadius = 0
                        self.likeEmojiView.transform = .identity
                        self.likeEmojiView.layer.opacity = 0
                    }
                }
            }
        }
    }
    
    @objc func buttonAnimate(sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
                sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    sender.transform = .identity
                }
            }
    }
    
    //MARK: - setConstraints
    
    private func setConstraints() {
        memeRequestTextfield.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memeRequestTextfield.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 25),
            memeRequestTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            memeRequestTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            memeRequestTextfield.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        getMemeRequestButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            getMemeRequestButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            getMemeRequestButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            getMemeRequestButton.topAnchor.constraint(equalTo: memeRequestTextfield.bottomAnchor, constant: 20),
            getMemeRequestButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        memeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memeImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            memeImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            memeImageView.topAnchor.constraint(equalTo: getMemeRequestButton.bottomAnchor, constant: 30),
            memeImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -160),
        ])
        
        reactionButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            reactionButtonsStackView.topAnchor.constraint(equalTo: memeImageView.bottomAnchor, constant: 10),
            reactionButtonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reactionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            reactionButtonsStackView.widthAnchor.constraint(equalToConstant: view.frame.width - 100)
        ])
        
        likeEmojiView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            likeEmojiView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            likeEmojiView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            likeEmojiView.widthAnchor.constraint(equalToConstant: 50),
            likeEmojiView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}

