//
//  WeeklyForecastData.swift
//  Weather
//
//  Created by Кирилл Давыденков on 24.03.2024.
//

import Foundation

struct FetchWeatherData: Decodable {
    let list: [List]
}

struct List: Decodable {
    let dt: Int
    let main: MainClass
    let weather: [WeekWeather]
}

struct MainClass: Decodable {
    let temp: Double
}

struct WeekWeather: Decodable {
    let id: Int
}
