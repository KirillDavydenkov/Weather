//
//  WeatherCell.swift
//  Weather
//
//  Created by Кирилл Давыденков on 23.03.2024.
//

import UIKit

class WeatherCell: UICollectionViewCell {
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        addSubview(dateLabel)
        addSubview(imageView)
        addSubview(temperatureLabel)
        
        dateLabel.font = UIFont.systemFont(ofSize: 25)
        dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        dateLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -90).isActive = true

        temperatureLabel.font = UIFont.systemFont(ofSize: 25)
        temperatureLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        temperatureLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
    }
    
}
