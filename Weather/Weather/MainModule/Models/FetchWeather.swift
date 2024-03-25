//
//  FetchWeather.swift
//  Weather
//
//  Created by Кирилл Давыденков on 24.03.2024.
//

import Foundation

struct FetchWeather {
    
    let temperature: Double
    
    var temperatureString: String {
        return String(format: "%.0f%°С", temperature)
    }
    
    let conditionCode: Int
    var systemIconNameString: String {
        switch conditionCode {
        case 200...232: return "cloud.bolt.rain.fill"
        case 300...321: return "cloud.drizzle.fill"
        case 500...531: return "cloud.rain.fill"
        case 600...622: return "cloud.snow.fill"
        case 701...781: return "smoke.fill"
        case 800: return "sun.min.fill"
        case 801...804: return "cloud.fill"
        default: return "nosign"
        }
    }
    
    func getDate(forIndex index: Int) -> String {
         let tomorrow = Calendar.current.date(byAdding: .day, value: (index + 1), to: Date())
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "dd.MM"
         return dateFormatter.string(from: tomorrow!)
     }
    
    init?(fetchWeatherData: FetchWeatherData) {
        guard let firstWeather = fetchWeatherData.list.first?.weather.first else { return nil }
        
        temperature = fetchWeatherData.list.first?.main.temp ?? 0
        conditionCode = firstWeather.id
    }
}
