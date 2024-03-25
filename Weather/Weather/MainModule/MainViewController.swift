//
//  MainViewController.swift
//  Weather
//
//  Created by Кирилл Давыденков on 23.03.2024.
//

import Foundation
import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    var hasRequestedWeather = false
    
    let cityNameLabel = UILabel()
    let weatherImageView = UIImageView()
    let temperatureLabel = UILabel()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    var weeklyForecast: [FetchWeatherData] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var networkWeatherManager = NetworkWeatherManager()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        networkWeatherManager.onCompletion = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let currentWeather):
                self.updateInterfaceWith(weather: currentWeather)
            case .failure(let error):
                print("Error fetching weather data: \(error)")
                DispatchQueue.main.async {
                    self.setupUI()
                }
            }
        }
        
        networkWeatherManager.onWeeklyForecastCompletion = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let weeklyForecast):
                self.weeklyForecast = weeklyForecast
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            case .failure(let error):
                print("Error fetching weekly forecast: \(error)")
            }
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        setupUI()
    }
    
    func updateInterfaceWith(weather: CurrentWeather) {
        DispatchQueue.main.async {
            self.cityNameLabel.text = weather.cityName
            self.temperatureLabel.text = weather.temperatureString
            self.weatherImageView.image = UIImage(systemName: weather.systemIconNameString)
        }
    }
    
    func configure(cell: WeatherCell, with forecast: FetchWeatherData, atIndex index: Int) {
        guard let fetchWeather = FetchWeather(fetchWeatherData: forecast) else {
            return
        }
        cell.dateLabel.text = fetchWeather.getDate(forIndex: index)
        cell.temperatureLabel.text = fetchWeather.temperatureString
        cell.imageView.image = UIImage(systemName: fetchWeather.systemIconNameString)
    }
    
    private func setupUI() {
        setupSearchBarButton()
        setupCityLabel()
        setupWeatherImage()
        setupTempLabel()
        setupCollectionView()
    }
}

extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weeklyForecast.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weatherCell", for: indexPath) as? WeatherCell
        if let cell = cell {
            configure(cell: cell, with: weeklyForecast[indexPath.row], atIndex: indexPath.row)
        }
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let height: CGFloat = 60 // высота ячейки
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "forecastHeader", for: indexPath) as! ForecastHeaderView
            headerView.titleLabel.text = "Прогноз на неделю"
            return headerView
        }
        return UICollectionReusableView()
    }
    
    private func setupSearchBarButton() {
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        navigationItem.rightBarButtonItem = searchButton
    }
    
    @objc private func searchButtonTapped() {
        let searchViewController = SearchViewController()
        navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    func setupCityLabel() {
        view.addSubview(cityNameLabel)
        
        cityNameLabel.text = ""
        cityNameLabel.textAlignment = .center
        cityNameLabel.font = UIFont.systemFont(ofSize: 40, weight: .light)
        cityNameLabel.translatesAutoresizingMaskIntoConstraints = false
        cityNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cityNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -40).isActive = true
    }
    
    func setupWeatherImage() {
        view.addSubview(weatherImageView)
        let image = UIImage(systemName: "")?.withTintColor(.black)
        weatherImageView.image = image
        weatherImageView.contentMode = .scaleAspectFill
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        weatherImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        weatherImageView.topAnchor.constraint(equalTo: cityNameLabel.bottomAnchor, constant: 20).isActive = true
        weatherImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        weatherImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupTempLabel() {
        view.addSubview(temperatureLabel)
        temperatureLabel.text = ""
        temperatureLabel.textAlignment = .center
        temperatureLabel.font = UIFont.systemFont(ofSize: 50, weight: .light)
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        temperatureLabel.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 20).isActive = true
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: "weatherCell")
        collectionView.register(ForecastHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "forecastHeader")
        
        collectionView.backgroundColor = .white
        collectionView.layer.cornerRadius = 20
        collectionView.layer.masksToBounds = true
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 16),
            collectionView.heightAnchor.constraint(equalToConstant: 7 * 70) // Высота коллекции
        ])
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.layer.shadowColor = UIColor.black.cgColor
        collectionView.layer.shadowOpacity = 0.5
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        collectionView.layer.shadowRadius = 10
        collectionView.layer.masksToBounds = false
    }
    
    
    
}

// MARK: - CLLocationManagerDelegate

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if !hasRequestedWeather {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            networkWeatherManager.fetchCurrentWeather(forRequestType: .coordinate(latitude: latitude, longitude: longitude))
            networkWeatherManager.fetchWeeklyForecast(forRequestType: .coordinate(latitude: latitude, longitude: longitude))
            
            hasRequestedWeather = true
        }
    }
    
}
