//
//  ViewController.swift
//  Meme Prediction
//
//  Created by Евгений Васильев on 14.07.2025.
//

import UIKit

class ViewController: UIViewController {
    
    enum Constants {
        static let cellHeight: CGFloat = 230
        static let cellSpacing: CGFloat = 10
    }
    
    var memeMamager  = MemeManager()
    var memes : [Meme] = []
    var memeImageUrl = ""
    var memeImages : [UIImage] = []
    
    
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
        view.isHidden = true
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
//        button.addTarget(self, action: #selector(dislikeButtonTapped), for: .touchUpInside)
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
    
    lazy var memesCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.collectionView?.isScrollEnabled = false
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.clipsToBounds = false
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .cyan
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()
    
    //MARK: - Set Delegates
    
    func setDelegates() {
        memesCollectionView.delegate = self
        memesCollectionView.dataSource = self
        memesCollectionView.register(MemeCollectionViewCell.self, forCellWithReuseIdentifier: "MemeCell")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        setDelegates()
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
        view.addSubview(memesCollectionView)
    }
    
    //MARK: - Action Func
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }
    }
    
    @objc func getMemeButtonTapped(sender: UIButton) -> String {
        likeButton.isUserInteractionEnabled = true
        dislikeButton.isUserInteractionEnabled = true
        memesCollectionView.isUserInteractionEnabled = true
        memesCollectionView.isHidden = false
        buttonAnimate(sender: sender)
        memeMamager.getMeme { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let memes) :
                    self?.memes = memes
                    //self?.memeImageUrl = memes.randomElement()!.url
                    //self?.downloadImage(from: URL(string: self!.memeImageUrl)!)
                    for meme in memes {
                        if let url = URL(string: meme.url) {
                            self?.downloadImage(from: url) { image in
                                if let image = image {
                                    self?.memeImages.append(image)
                                }
                            }
                        }
                    }
                    UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseOut, animations: {
                        self?.reactionButtonsStackView.alpha = 1
                        self?.reactionButtonsStackView.transform = .identity})
                case.failure(let error) :
                    print(error.localizedDescription)
                }
            }
        }
        return memeImageUrl
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
        
        memesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memesCollectionView.topAnchor.constraint(equalTo: getMemeRequestButton.bottomAnchor, constant: 30),
            memesCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            memesCollectionView.heightAnchor.constraint(equalToConstant: Constants.cellHeight),
            memesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            memesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
}

//MARK: - Extensions

extension ViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCell", for: indexPath) as?
                MemeCollectionViewCell else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let avialableWidth = (collectionView.frame.width - (Constants.cellSpacing * 2))/3
        return CGSize(width: avialableWidth, height: Constants.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MemeCollectionViewCell else { return }
        cell.imageView.image = memeImages.randomElement()
    }
}
