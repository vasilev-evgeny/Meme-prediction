//
//  SavesMemesUIView.swift
//  Meme Prediction
//
//  Created by Евгений Васильев on 16.07.2025.
//
import UIKit

class SavedMemesCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let savedImageImageView : UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.layer.cornerRadius = 5
        view.backgroundColor = .black
        return view
    }()
    
    let savedRequestLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private func setupViews() {
        contentView.addSubview(savedImageImageView)
        contentView.addSubview(savedRequestLabel)
        savedImageImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedImageImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            savedImageImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            savedImageImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            savedImageImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        savedRequestLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            savedRequestLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            savedRequestLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            savedRequestLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            savedRequestLabel.leadingAnchor.constraint(equalTo: savedImageImageView.trailingAnchor, constant: 20)
        ])
    }
}
