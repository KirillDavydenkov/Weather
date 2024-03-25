//
//  SearchViewController.swift
//  Weather
//
//  Created by Кирилл Давыденков on 24.03.2024.
//

import UIKit

class SearchViewController: UIViewController {
    
    let searchCityLabel = UILabel()
    let searchTempLabel = UILabel()
    let searchWeatherIcon = UIImageView()
    
    var networkWeatherManager = NetworkWeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        networkWeatherManager.onCompletion = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let currentWeather):
                updateInterfaceWith(weather: currentWeather)
            case .failure(let error):
                print("Error fetching weather data: \(error)")
            }
        }
        
        func updateInterfaceWith(weather: CurrentWeather) {
            DispatchQueue.main.async {
                self.searchCityLabel.text = "\(weather.cityName)"
                self.searchTempLabel.text = "\(weather.temperatureString)"
                self.searchWeatherIcon.image = UIImage(systemName: weather.systemIconNameString)
            }
        }
        
        setupSearchUI()
    }
    
    func setupSearchUI() {
        presentCityInputAlert()
        setupSearchCityLabel()
        setupSearchTempLabel()
        setupSearchWeatherCodeLabel()
    }
}


extension SearchViewController {
    
    func presentCityInputAlert() {
        let alert = UIAlertController(title: "Введите город", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Город"
        }
        let submitAction = UIAlertAction(title: "OK", style: .default) { [weak self, weak alert] _ in
            guard let city = alert?.textFields?.first?.text else { return }
            self?.networkWeatherManager.fetchCurrentWeather(forRequestType: .cityName(city: city))
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(submitAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func setupSearchCityLabel() {
        searchCityLabel.textAlignment = .center
        searchCityLabel.font = UIFont.systemFont(ofSize: 40, weight: .light)
        searchCityLabel.numberOfLines = 0 // Для отображения нескольких строк, если текст слишком длинный
        searchCityLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchCityLabel)
        
        searchCityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchCityLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
    }
    
    func setupSearchWeatherCodeLabel() {
        view.addSubview(searchWeatherIcon)
        let image = UIImage(systemName: "")?.withTintColor(.black)
        searchWeatherIcon.image = image
        searchWeatherIcon.contentMode = .scaleAspectFill
        searchWeatherIcon.translatesAutoresizingMaskIntoConstraints = false
        searchWeatherIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchWeatherIcon.topAnchor.constraint(equalTo: searchCityLabel.bottomAnchor, constant: 20).isActive = true
        searchWeatherIcon.widthAnchor.constraint(equalToConstant: 100).isActive = true
        searchWeatherIcon.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func setupSearchTempLabel() {
        searchTempLabel.textAlignment = .center
        searchTempLabel.font = UIFont.systemFont(ofSize: 50, weight: .light)
        searchTempLabel.numberOfLines = 0
        searchTempLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchTempLabel)
        
        searchTempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchTempLabel.topAnchor.constraint(equalTo: searchCityLabel.bottomAnchor, constant: 140).isActive = true
    }
    
}
