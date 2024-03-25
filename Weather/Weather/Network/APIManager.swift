//
//  APIManager.swift
//  Weather
//
//  Created by Кирилл Давыденков on 23.03.2024.
//

import Foundation
import CoreLocation

let apiKey = "e9414f839df6720f26f4ffb3fb6c635a"

class NetworkWeatherManager {
    
    enum RequestType {
        case cityName(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }
    
    var onCompletion: ((Result<CurrentWeather, Error>) -> Void)?
    var onWeeklyForecastCompletion: ((Result<[FetchWeatherData], Error>) -> Void)?

    func fetchCurrentWeather(forRequestType requestType: RequestType) {
        var urlString = ""
        switch requestType {
        case  .cityName(let city):
            urlString =
            "https://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(apiKey)&units=metric"
            print(requestType)
        case .coordinate(let latitude, let longitude):
            urlString =
            "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
        }
        performRequest(withURLString: urlString)
    }
    
    func fetchWeeklyForecast(forRequestType requestType: RequestType) {
        var urlString = ""
        switch requestType {
        case  .cityName(let city):
            urlString =
            "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric&cnt=7"
        case .coordinate(let latitude, let longitude):
            urlString =
            "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric&cnt=7"
        }
        performWeeklyForecastRequest(withURLString: urlString)
    }
    
    fileprivate func performRequest(withURLString urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                self.onCompletion?(.failure(error))
                return
            }
            if let data = data {
                if let currentWeather = self.parseJSON(withData: data) {
                    self.onCompletion?(.success(currentWeather))
                    print(currentWeather)
                }
            }
        }
        task.resume()
    }
    
    fileprivate func performWeeklyForecastRequest(withURLString urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                self.onWeeklyForecastCompletion?(.failure(error))
                return
            }
            
            if let data = data {
                if let weeklyForecast = self.parseWeeklyForecast(withData: data) {
                    self.onWeeklyForecastCompletion?(.success(weeklyForecast))
                }
            }
        }
        task.resume()
    }

    fileprivate func parseWeeklyForecast(withData data: Data) -> [FetchWeatherData]? {
        let decoder = JSONDecoder()
        do {
            let weeklyForecastData = try decoder.decode(FetchWeatherData.self, from: data)
            let fetchWeatherDataList = weeklyForecastData.list.map { list in
                return FetchWeatherData(list: [list])
            }
    
            return fetchWeatherDataList
        } catch {
            print("Error parsing weekly forecast data:", error)
            return nil
        }
    }

    fileprivate func parseJSON(withData data: Data) -> CurrentWeather? {
        do {
            let decoder = JSONDecoder()
            let currentWeatherData = try decoder.decode(CurrentWeatherData.self, from: data)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil
            }
            print(currentWeather)
            return currentWeather
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
            return nil
        }
    }
}
