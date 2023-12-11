//
//  WeatherManager.swift
//  Clima
//
//  Created by Prabhas Chinthala on 04/11/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    let weatherUrl="https://api.openweathermap.org/data/2.5/weather?APPID=701a15b70a1a5310e4e67b092df08f63&units=metric"
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherUrl)&q=\(cityName)"
        performRequest(with:urlString)
        
    }
    
    func fetchWeather(latitude : CLLocationDegrees ,longitude : CLLocationDegrees ){
        
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
        
    }
    
    func performRequest(with urlString: String){
        
        //  1. create a URL
            
        if let url=URL(string: urlString){
            
            //  2. create a URL session
            
            let session = URLSession(configuration: .default)
            
            //  3. Give the session a task
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let weather = parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather:weather)
                    }
                }
            }
            
            //  4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temperature = decodedData.main.temp
            let cityName = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: cityName, temperature: temperature)
            return weather
            
        }
        catch{
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
   
    
   
}
