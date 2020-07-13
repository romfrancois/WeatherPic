//
//  WeatherDetail.swift
//  WeatherPic
//
//  Created by Romain Francois on 07/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import Foundation

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    
    return dateFormatter
}()

private let hourFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ha"
    
    return dateFormatter
}()

struct DailyWeather {
    var dailyIcon: String
    var dailyWeekday: String
    var dailySummary: String
    var dailyHigh: Int
    var dailyLow: Int
}

struct HourlyWeather {
    var hour: String
    var hourlyTemperature: Int
    var hourlyIcon: String
}

class WeatherDetail: WeatherLocation {
    
    private struct Result: Codable {
        var timezone: String
        var current: Current
        var daily: [Daily]
        var hourly: [Hourly]
    }
    
    private struct Current: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    private struct Weather: Codable {
        var description: String
        var icon: String
        var id: Int
    }
    
    private struct Temp: Codable {
        var max: Double
        var min: Double
    }
    
    private struct Daily: Codable {
        var dt: TimeInterval
        var temp: Temp
        var weather: [Weather]
    }
    
    private struct Hourly: Codable {
        var dt: TimeInterval
        var temp: Double
        var weather: [Weather]
    }
    
    var timezone = ""
    var currentTime = 0.0
    var temperature = 0
    var summary = ""
    var dayIcon = ""
    
    var dailyWeatherData: [DailyWeather] = []
    var hourlyWeatherData: [HourlyWeather] = []
    
    func getData(completed: @escaping () -> ()) {
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&appid=\(APIkeys.openWeatherKey)"
        
        // Create a URL
        guard let url = URL(string: urlString) else {
            print("ERROR: Couldn't create a URL from \(urlString)")
            completed()
            return
        }
        
        // Create session
        let session = URLSession.shared
        
        // get data with .dataTask method
        let task = session.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("ERROR: \(error.localizedDescription)")
            }
            
            // deal with the data
            do {
                // let json = try JSONSerialization.jsonObject(with: data!, options: [])
                // print("json: \(json)")
                let result = try JSONDecoder().decode(Result.self, from: data!)
                self.timezone = result.timezone
                self.currentTime = result.current.dt
                self.temperature = Int(result.current.temp.rounded())
                self.summary = result.current.weather[0].description
                self.dayIcon = self.fileNameForIcon(iconName: result.current.weather[0].icon)

                for index in 0..<result.daily.count {
                    let weekdayDate = Date(timeIntervalSince1970: result.daily[index].dt)
                    dateFormatter.timeZone = TimeZone(identifier: result.timezone)
                    let dailyWeekday = dateFormatter.string(from: weekdayDate)
                    
                    let dailyIcon = self.fileNameForIcon(iconName: result.daily[index].weather[0].icon)
                    let dailySummary = result.daily[index].weather[0].description
                    let dailyHigh = Int(result.daily[index].temp.max.rounded())
                    let dailyLow = Int(result.daily[index].temp.min.rounded())
                    
                    let dailyWeather = DailyWeather(dailyIcon: dailyIcon, dailyWeekday: dailyWeekday, dailySummary: dailySummary, dailyHigh: dailyHigh, dailyLow: dailyLow)
                    
                    self.dailyWeatherData.append(dailyWeather)
                    
                }
                
                // get no more than 24h or hourly data
                let lastHour = min(24, result.hourly.count)
                if lastHour > 0 {  // 1 because of the first item to be the same as main one
                    for index in 1...lastHour {
                        let hourlyDate = Date(timeIntervalSince1970: result.hourly[index].dt)
                        hourFormatter.timeZone = TimeZone(identifier: result.timezone)
                        let hour = hourFormatter.string(from: hourlyDate)
                        
//                        let hourlyIcon = self.fileNameForIcon(iconName: result.hourly[index].weather[0].icon)
                        let hourlyIcon = self.systemNameFromId(id: result.hourly[index].weather[0].id, icon: result.hourly[index].weather[0].icon)
                        let hourlyTemp = Int(result.hourly[index].temp.rounded())
                        
                        let hourlyWeather = HourlyWeather(hour: hour, hourlyTemperature: hourlyTemp, hourlyIcon: hourlyIcon)
                        
                        self.hourlyWeatherData.append(hourlyWeather)
                        
                    }
                }
            } catch {
                print("JSON ERROR: \(error.localizedDescription)")
            }
            completed()
        }
        
        task.resume()
    }
    
    func fileNameForIcon(iconName icon: String) -> String {
        switch icon {
            case "01d":
                let imageNumber = Int.random(in: 1...18)
                return "clear-day-\(imageNumber)"
            
            case "01n":
                return "clear-night"
            
            case "02d":
                return "partly-cloudy-day"
            
            case "02n":
                return "partly-cloudy-night"
            
            case "03d", "03n", "04d", "04n":
                let imageNumber = Int.random(in: 1...4)
                return "cloudy-\(imageNumber)"
            
            case "09d", "09n", "10d", "10n":
                return "rain"
            
            case "11d", "11n":
                return "thunderstorm"
            
            case "13d", "13n":
                return "snow"
            
            case "50d", "50n":
                return "fog"
            
            default:
                return ""
        }
    }
    
    private func systemNameFromId(id: Int, icon: String) -> String {
        switch id {
        case 200...299:
            return "cloud.bolt.rain"
        case 300...399:
            return "cloud.drizzle"
        case 500, 501, 520, 521, 531:
            return "cloud.rain"
        case 502, 503, 504, 522:
            return "cloud.heavyrain"
        case 511, 611...616:
            return "sleet"
        case 600...602, 620...622:
            return "snow"
        case 701, 711, 741:
            return "cloud.fog"
        case 721:
            return (icon.hasSuffix("d") ? "sun.haze" : "cloud.fog")
        case 731, 751, 761, 762:
            return (icon.hasSuffix("d") ? "sun.dust" : "cloud.fog")
        case 771:
            return "wind"
        case 781:
            return "tornado"
        case 800:
            return (icon.hasSuffix("d") ? "sun.max" : "moon")
        case 801, 802:
            return (icon.hasSuffix("d") ? "cloud.sun" : "cloud.moon")
        case 803, 804:
            return "cloud"
        default:
            return "questionmark.diamond"
        }
    }
}
