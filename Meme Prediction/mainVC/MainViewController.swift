//
//  ViewController.swift
//  Meme Prediction
//
//  Created by Евгений Васильев on 14.07.2025.
//

import UIKit

class MainViewController: UIViewController {
    
    enum Constants {
        static let cellHeight: CGFloat = 230
        static let cellSpacing: CGFloat = 10
    }
    
    var memeMamager  = MemeManager()
    var memes : [Meme] = []
    var memeImageUrl = ""
    var memeImages : [UIImage] = []
    var reactionButtonAvilable = false
    var savedImages : [UIImage] = []
    var savedRequests : [String] = []
    
    private var lastSelectedIndexPath: IndexPath?
    
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
        button.titleLabel?.textColor = .white
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
    
    lazy var likeButton : UIButton = {
        let button = UIButton()
        button.setTitle("👍🏻", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var dislikeButton : UIButton = {
        let button = UIButton()
        button.setTitle("👎🏻", for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(dislikeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var reactionButtonsStackView : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 20
        view.distribution = .fillEqually
        view.alpha = 0
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
        view.isUserInteractionEnabled = false
        view.isHidden = true
        view.allowsSelection = true
        view.allowsMultipleSelection = false
        return view
    }()
    
    let savedMemesButton : UIButton = {
        let button = UIButton()
        button.setTitle("Сохраненные предсказания", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .magenta
        button.layer.cornerRadius = 10
        button.isHidden = false
        button.addTarget(self, action: #selector(savedMemesButtonTapped), for: .touchUpInside)
        return button
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
        view.addSubview(savedMemesButton)
        view.addSubview(memesCollectionView)
    }
    
    //MARK: - Action Func
    
    @objc func savedMemesButtonTapped(sender: UIButton) {
        buttonAnimate(sender: sender)
        print("\(savedImages.count)")
        print("\(savedRequests.count)")
        let vc = SavedMemViewController()
        vc.savedMemeImages = savedImages
        vc.savedMemeRequests = savedRequests
        self.present(vc, animated: true)
    }
    
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
        memesCollectionView.isUserInteractionEnabled = true
        memesCollectionView.alpha = 0
        memesCollectionView.transform = CGAffineTransform(translationX: 0, y: 50)
        memesCollectionView.isHidden = false
        buttonAnimate(sender: sender)
        memeMamager.getMeme { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let memes) :
                    self?.memes = memes
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
                                        self?.memesCollectionView.alpha = 1
                                        self?.memesCollectionView.transform = .identity
                                    })
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
    
    func saveReuestNClear() {
        if memeRequestTextfield.text != nil {
            savedRequests.append(memeRequestTextfield.text!)
        } else {
            print("Введи предсказание")
        }
    }
    @objc func likeButtonTapped(sender: UIButton) {
        buttonAnimate(sender: sender)
        saveReuestNClear()
        likeAnimation()
        dislikeButton.isUserInteractionEnabled = false
        likeButton.isUserInteractionEnabled = false
        reactionButtonAvilable = false
        let indexPath = lastSelectedIndexPath
        self.collectionView(self.memesCollectionView, didDeselectItemAt: indexPath!)
        guard let indexPath = lastSelectedIndexPath,
                  let cell = memesCollectionView.cellForItem(at: indexPath) as? MemeCollectionViewCell,
                  let imageToSave = cell.imageView.image else { return }
        savedImages.append(imageToSave)
        for cell in self.memesCollectionView.visibleCells {
            if let memeCell = cell as? MemeCollectionViewCell {
                memeCell.imageView.image = nil
                memeCell.imageView.backgroundColor = .black
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.animateCellsDisappearance {
                self.memesCollectionView.isUserInteractionEnabled = true
            }
        }
    }

    @objc func likeAnimation() {
        guard let indexPath = lastSelectedIndexPath,
        let cell = memesCollectionView.cellForItem(at: indexPath) else { return }
            UIView.animate(withDuration: 0.35) {
                cell.layer.shadowColor = UIColor.green.cgColor
                cell.layer.shadowOpacity = 0.5
                cell.layer.shadowRadius = 45
            } completion: { done in
                if done {
                    UIView.animate(withDuration: 0.7) {
                        cell.layer.shadowColor = UIColor.green.cgColor
                        cell.layer.shadowOpacity = 1
                        cell.layer.shadowRadius = 70
                    } completion: { done in
                        if done {
                            cell.layer.shadowColor = UIColor.clear.cgColor
                            cell.layer.shadowOpacity = 0
                            cell.layer.shadowRadius = 0
                        }
                    }
                }
            }
        }
    
    @objc func buttonAnimate(sender: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                sender.transform = .identity
            }
        }
    }
    
    private func animateCellsDisappearance(completion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: 0.8,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.8,
            options: .curveEaseOut,
            animations: {
                for cell in self.memesCollectionView.visibleCells {
                    cell.transform = CGAffineTransform(translationX: -self.memesCollectionView.bounds.width, y: 0)
                    cell.alpha = 0
                }
            },
            completion: { _ in
                for cell in self.memesCollectionView.visibleCells {
                    cell.transform = .identity
                    cell.alpha = 0
                }
                self.memesCollectionView.reloadData()
                UIView.animate(
                    withDuration: 0.8,
                    delay: 0,
                    usingSpringWithDamping: 1,
                    initialSpringVelocity: 0.8,
                    options: .curveEaseOut,
                    animations: {
                        for cell in self.memesCollectionView.visibleCells {
                            cell.alpha = 1
                        }
                    },
                    completion: { _ in
                        completion?()
                    }
                )
            }
        )
    }
    
    @objc func dislikeButtonTapped(sender: UIButton) {
        buttonAnimate(sender: sender)
        dislikeButton.isUserInteractionEnabled = false
        likeButton.isUserInteractionEnabled = false
        reactionButtonAvilable = false
        changeButtonsColor()
        let indexPath = lastSelectedIndexPath
        self.collectionView(self.memesCollectionView, didDeselectItemAt: indexPath!)
        for cell in self.memesCollectionView.visibleCells {
            if let memeCell = cell as? MemeCollectionViewCell {
                memeCell.imageView.image = nil
                memeCell.imageView.backgroundColor = .black
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            self.animateCellsDisappearance {
                self.memesCollectionView.isUserInteractionEnabled = true
            }
        }
    }
    
    func changeButtonsColor() {
        if reactionButtonAvilable == false {
            UIView.animate(withDuration: 1) {
                self.dislikeButton.layer.opacity = 0.5
                self.likeButton.layer.opacity = 0.5
            } completion: { _ in
                self.dislikeButton.backgroundColor = .gray
                self.likeButton.backgroundColor = .gray
                self.dislikeButton.layer.opacity = 1
                self.likeButton.layer.opacity = 1
            }

        } else {
            UIView.animate(withDuration: 0.3) {
                self.dislikeButton.layer.opacity = 0.5
                self.likeButton.layer.opacity = 0.5
            } completion: { _ in
                self.dislikeButton.backgroundColor = .systemRed
                self.likeButton.backgroundColor = .systemGreen
                self.dislikeButton.layer.opacity = 1
                self.likeButton.layer.opacity = 1
            }
        }
    }
    
    //MARK: - setConstraints
    
    private func setConstraints() {
        memeRequestTextfield.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memeRequestTextfield.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 50),
            memeRequestTextfield.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            memeRequestTextfield.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            memeRequestTextfield.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        getMemeRequestButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            getMemeRequestButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            getMemeRequestButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
            reactionButtonsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            reactionButtonsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
            reactionButtonsStackView.widthAnchor.constraint(equalToConstant: 200),
            reactionButtonsStackView.heightAnchor.constraint(equalToConstant: 150)
        ])

        memesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            memesCollectionView.topAnchor.constraint(equalTo: getMemeRequestButton.bottomAnchor, constant: 30),
            memesCollectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            memesCollectionView.heightAnchor.constraint(equalToConstant: Constants.cellHeight),
            memesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 10),
            memesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        savedMemesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedMemesButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            savedMemesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            savedMemesButton.leadingAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
}

//MARK: - Extensions CollectionView

extension MainViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    
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
        reactionButtonAvilable = true
        changeButtonsColor()
        lastSelectedIndexPath = indexPath
        likeButton.isUserInteractionEnabled = true
        dislikeButton.isUserInteractionEnabled = true
        memesCollectionView.isUserInteractionEnabled = false
        guard let cell = collectionView.cellForItem(at: indexPath) as? MemeCollectionViewCell else { return }
        if cell.transform != .identity {
                UIView.animate(withDuration: 0.5) {
                    cell.transform = .identity
                    cell.layer.zPosition = 0
                    cell.imageView.contentMode = .scaleAspectFit
                }
                collectionView.deselectItem(at: indexPath, animated: true)
                return
            }
        cell.imageView.image = memeImages.randomElement()
        cell.layer.zPosition = 1
        cell.imageView.contentMode = .scaleAspectFit
        let centerX = collectionView.frame.width / 2 - cell.frame.width / 2
        let centerY = collectionView.frame.height / 2 - cell.frame.height / 2

        UIView.animate(withDuration: 0.1, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                cell.transform = CGAffineTransform(translationX: centerX - cell.frame.origin.x, y: centerY - cell.frame.origin.y)
                            .scaledBy(x: 3, y: 3)
                cell.preservesSuperviewLayoutMargins = false
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MemeCollectionViewCell else { return }
        UIView.animate(withDuration: 0.7) {
            cell.transform = .identity
            cell.layer.zPosition = 0
        }
    }
    
}

//MARK: - Extensions TextField

extension MainViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        savedRequests.append(textField.text!)
    }
}
