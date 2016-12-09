//
//  WeatherServices.swift
//  FinalWeather
//
//  Created by JingJing HAO on 12/7/16.
//  Copyright © 2016 JingJing. All rights reserved.
//

import Foundation

typealias WeatherCompletionHandler = (Weather?, NSError?) -> Void

class WeatherServices: NSObject{
    
    fileprivate let openWeatherMapURL       = "http://api.openweathermap.org/data/2.5/forecast"
    fileprivate let openWeatherMapAPIKey    = "c7a3f5ff26fe45c016e5117cac1d6f77"

    fileprivate func getNextDaysForecasts(_ json: JSON) -> [Forecast] {
        var forecasts: [Forecast] = []
        
        for index in 1...6 {
            guard let tempDegrees = json["list"][0]["main"]["temp"].double,
                let city        = json["city"]["name"].string,
                let pressure    = json["list"][0]["main"]["pressure"].double,
                let humidity    = json["list"][0]["main"]["humidity"].int,
                let windSpeed   = json["list"][0]["wind"]["speed"].double,
                let windDeg     = json["list"][0]["wind"]["deg"].int else {
                break;
            }

            let country = json["city"]["country"].string
            let forecastTemperature = Temperature(country: country!,
                                                  openWeatherMapDegrees: forecastTempDegrees)
            let forecastTimeString = ForecastDateTime(rawDateTime).shortTime
            let weatherIcon = WeatherIcon(condition: forecastCondition, iconString: forecastIcon)
            let forcastIconText = weatherIcon.iconText
            
            let forecast = Forecast(time: forecastTimeString,
                                    iconText: forcastIconText,
                                    temperature: forecastTemperature.degrees)
            
            forecasts.append(forecast)
        }
        
        return forecasts
    }

    
    //MARK: - Get Current Weather
    func currentWeatherByCityName(city:NSString,completionHandler: @escaping WeatherCompletionHandler){
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        
       // let weatherRequestURL = URL(string: "\(openWeatherMapURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        
        let aStrUrl = "\(openWeatherMapURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)"
            //String(format: "http://smartnsoft.com/shared/weather/index.php?city=%@&forecasts=%@",city, String(days))
        
        let urlEncoded = aStrUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let weatherRequestURL = URL(string: urlEncoded!)
        
        let request = URLRequest(url: weatherRequestURL!)
        
        // The data task get the data.
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            // Get networkError while geting date from the server
            guard error == nil else {
                //let error = Error(errorCode: .networkRequestFailed)
                completionHandler(nil, error as NSError?)
                
                return
            }
            
            // Check JSON serialization error
            guard let unwrappedData = data else {
                completionHandler(nil, error as NSError?)
                return
            }
            
            let json = JSON(data: unwrappedData)
            
            // Get all information and check parsing error
            guard let tempDegrees = json["main"]["temp"].double,
                let city        = json["city"]["name"].string,
                let pressure    = json["main"]["pressure"].double,
                let humidity    = json["main"]["humidity"].int,
                let windSpeed   = json["wind"]["speed"].double,
                let windDeg     = json["wind"]["deg"].int else {
                    completionHandler(nil, error as NSError?)
                    return
            }
            
            let celsiusTemp = tempDegrees - 273.15
            let degrees  = String(format: "%.0f", celsiusTemp)

            let weather = Weather(city:city,temperature:degrees, pressure:pressure, humidity:humidity, windSpeed:windSpeed, windDeg: windDeg, forecastsArray: forecasts)

//            var weatherBuilder = W()
//            let temperature = Temperature(country: country, openWeatherMapDegrees:tempDegrees)
//            weatherBuilder.temperature = temperature.degrees
//            weatherBuilder.location = city
//            
//            let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
//            weatherBuilder.iconText = weatherIcon.iconText
//            
//            
//            weatherBuilder.forecasts = self.getFirstFourForecasts(json)
//            
//            completionHandler(weatherBuilder.build(), nil)
            
            self.writeToJsonFile(json)
            
            completionHandler(self.parseJson(json), nil)
            
        })
        
        task.resume()
    }

    
    // MARK: loadWeather from JSONFILE
    
    func loadJson(_ filePath: String ,completionHandler: (Weather?, NSError?) -> Void){
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: NSData.ReadingOptions.mappedIfSafe)
            let jsonObj = JSON(data: data)
            if jsonObj != JSON.null {
                completionHandler(self.parseJson(jsonObj), nil)
                
            } else {
                print("could not get json from file, make sure that file contains valid json.")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            completionHandler(nil, error)
            
        }
    }
    
    // MARK: Parse JSON
    func parseJson(_ json:JSON)->Weather?
    {
        print("Date and time: \(weather["dt"]!)")
        print("City: \(weather["name"]!)")
        
        print("Longitude: \(weather["coord"]!["lon"]!!)")
        print("Latitude: \(weather["coord"]!["lat"]!!)")
        
        print("Weather ID: \(weather["weather"]![0]!["id"]!!)")
        print("Weather main: \(weather["weather"]![0]!["main"]!!)")
        print("Weather description: \(weather["weather"]![0]!["description"]!!)")
        print("Weather icon ID: \(weather["weather"]![0]!["icon"]!!)")
        
        print("Temperature: \(weather["main"]!["temp"]!!)")
        print("Humidity: \(weather["main"]!["humidity"]!!)")
        print("Pressure: \(weather["main"]!["pressure"]!!)")
        
        print("Cloud cover: \(weather["clouds"]!["all"]!!)")
        
        print("Wind direction: \(weather["wind"]!["deg"]!!) degrees")
        print("Wind speed: \(weather["wind"]!["speed"]!!)")
        
        print("Country: \(weather["sys"]!["country"]!!)")
        print("Sunrise: \(weather["sys"]!["sunrise"]!!)")
        print("Sunset: \(weather["sys"]!["sunset"]!!)")
        

        var weatherBuilder = WeatherBuilder()
        let temperature = Temperature(country: country, openWeatherMapDegrees:tempDegrees)
        weatherBuilder.temperature = temperature.degrees
        weatherBuilder.location = city
        
        let weatherIcon = WeatherIcon(condition: weatherCondition, iconString: iconString)
        weatherBuilder.iconText = weatherIcon.iconText
        
        
        weatherBuilder.forecasts = self.getFirstFourForecasts(json)
        
        completionHandler(weatherBuilder.build(), nil)
        let city = json["name"].string
        let temperature = json["main"]!["temp"]
        var forecasts = [Forecast]()
        for index in 0..<json["forecasts"].count{
            
            let forecast = Forecast()
            forecast.date = json["forecasts"][index]["date"].string
            forecast.tempsMin = json["forecasts"][index]["temperatureMin"].int!
            forecast.tempsMax = json["forecasts"][index]["temperatureMax"].int!
            forecast.type = json["forecasts"][index]["type"].string!
            forecast.uvIndex = json["forecasts"][index]["uvIndex"].int!
            forecast.windDirection = json["forecasts"][index]["windDirection"].string!
            forecast.windSpeed = json["forecasts"][index]["windSpeed"].int!
            forecasts.append(forecast)
            
        }
        
        let weather = Weather(city: city!,temperature  forecastsArray: forecasts)
        
        return weather
        
    }
    
    // MARK: Write JSON to File
    func writeToJsonFile(_ json:JSON)->Void
    {
        
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent("weather.json")
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        if fileManager.fileExists(atPath: jsonFilePath.absoluteString, isDirectory: &isDirectory) {
            do {
                try fileManager.removeItem(atPath: jsonFilePath.absoluteString)
                print("File removed")
                
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
            
        }
        
        let created = fileManager.createFile(atPath: jsonFilePath.absoluteString, contents: nil, attributes: nil)
        if created {
            print("File created ")
        } else {
            print("Couldn't create file for some reason")
        }
        
        let str = json.description
        let jsonData = str.data(using: String.Encoding.utf8)!
        
        // Write that JSON to the file created earlier
        do {
            let file = try FileHandle(forWritingTo: jsonFilePath)
            file.write(jsonData)
            print("JSON data was written to teh file successfully!")
        } catch let error as NSError {
            print("Couldn't write to file: \(error.localizedDescription)")
        }
        
    }



}
