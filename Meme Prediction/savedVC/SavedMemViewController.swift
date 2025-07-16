//
//  SavedMemViewController.swift
//  Meme Prediction
//
//  Created by Евгений Васильев on 16.07.2025.
//
import UIKit

class SavedMemViewController : UIViewController {
    
    enum Constants {
        
    }
    
    var savedMemeImages : [UIImage] = [UIImage(imageLiteralResourceName: "icons8"),UIImage(imageLiteralResourceName: "icons8"),UIImage(imageLiteralResourceName: "icons8"),UIImage(imageLiteralResourceName: "icons8"),UIImage(imageLiteralResourceName: "icons8"),UIImage(imageLiteralResourceName: "icons8"),UIImage(imageLiteralResourceName: "icons8"),UIImage(imageLiteralResourceName: "icons8"),UIImage(imageLiteralResourceName: "icons8")]
    var savedMemeRequests : [String] = ["lupa","lupa","lupa","lupa","lupa","lupa","lupa","lupa","lupa","lupa"]
    
    //MARK: - Create UI
    
    let savedMemeCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    //MARK: - Set Delegates
    
     func setDelegates() {
        savedMemeCollectionView.delegate = self
        savedMemeCollectionView.dataSource = self
        savedMemeCollectionView.register(SavedMemesCell.self, forCellWithReuseIdentifier: "SaveMemCell")
    }
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setConstraints()
        setDelegates()
        navigationItem.backButtonTitle = "Back"
        navigationController?.navigationItem.backButtonDisplayMode = .default
    }
    
    private func setupViews() {
        view.addSubview(savedMemeCollectionView)
    }
    
    //MARK: - setConstraints
    
    private func setConstraints() {
        savedMemeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedMemeCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            savedMemeCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            savedMemeCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            savedMemeCollectionView.topAnchor.constraint(equalTo: view.topAnchor)
        ])
    }
}

extension SavedMemViewController : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource  {
    
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return savedMemeImages.count
    }
    
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SaveMemCell", for: indexPath) as?
                SavedMemesCell else {
            return UICollectionViewCell()
        }
         cell.savedImageImageView.image = savedMemeImages[indexPath.item]
         cell.savedRequestLabel.text = savedMemeRequests[indexPath.item]
        return cell
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 20, height: 200)
    }
}
