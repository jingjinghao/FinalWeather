//
//  WeatherManager.swift
//  FinalWeather
//
//  Created by JingJing HAO on 12/8/16.
//  Copyright © 2016 JingJing. All rights reserved.
//

import Foundation

extension String {
    func replace(_ string:String, replacement:String) -> String {
        return self.replacingOccurrences(of: string,
                                         with: replacement,
                                         options: NSString.CompareOptions.literal,
                                         range: nil)
    }
    
    func replaceWhitespace() -> String {
        return self.replace(" ", replacement: "+")
    }
}

public enum WeatherResult {
    case Success(JSON)
    case Error(String)
    
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Error:
            return false
        }
    }
}

class WeatherManager: NSObject{
    
    fileprivate let openWeatherMapURL       = "http://api.openweathermap.org/data/2.5/"
    fileprivate let openWeatherMapAPIKey    = "c7a3f5ff26fe45c016e5117cac1d6f77"
    
    func getForecasts(_ json: JSON) -> [Forecast] {
        var forecasts: [Forecast] = []
        
        for (index,_) in json["list"].enumerated(){
            guard  let dateDouble = json["list"][index]["dt"].double,
                let tempsMin = json["list"][index]["temp"]["min"].double,
                let tempsMax = json["list"][index]["temp"]["max"].double,
                let weatherDes = json["list"][index]["weather"][0]["main"].string,
                let pressure = json["list"][index]["pressure"].double,
                let humidity = json["list"][index]["humidity"].int,
                let windSpeed = json["list"][index]["speed"].double,
                let windDeg =  json["list"][index]["deg"].int else {
                    break
            }
            
            let forecast = Forecast(dateDouble,tempsMin,tempsMax,weatherDes,pressure,humidity,windSpeed,windDeg)
            forecasts.append(forecast)
        }
        
        return forecasts
    }

    // MARK: Get Current Weather
    func currentWeatherWithCityName(_ cityName: String, completionHandler: @escaping (WeatherResult) -> ()) {
        sendRequest("/weather?q=\(cityName.replaceWhitespace())", completionHandler: completionHandler)
    }
    
    // MARK: Get Daily Forecast
    func dailyForecastWithCityName(_ cityName: String, completionHandler: @escaping (WeatherResult) -> ()) {
        sendRequest("/forecast/daily?q=\(cityName.replaceWhitespace())", completionHandler: completionHandler)
    }
    
    
    // MARK: SendRequest
    fileprivate func sendRequest(_ method: String, completionHandler: @escaping (WeatherResult) -> ()) {
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        
        let aStrUrl = openWeatherMapURL + method + "&APPID=\(openWeatherMapAPIKey)&units=metric"

        let urlEncoded = aStrUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        let weatherRequestURL = URL(string: urlEncoded!)
        
        let request = URLRequest(url: weatherRequestURL!)
        
        // The data task get the data.
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard let unwrappedData = data else {
                completionHandler(WeatherResult.Error(error.debugDescription))
                return
            }
            let json = JSON(data: unwrappedData)
            completionHandler(WeatherResult.Success(json))
            
        })
        
        task.resume()
    }
    
    // MARK: Load from JSONFILE
    func loadJson(_ filePath: String ,completionHandler: @escaping (WeatherResult) -> ()){
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: NSData.ReadingOptions.mappedIfSafe)
            let jsonObj = JSON(data: data)
            if jsonObj != JSON.null {
                completionHandler(WeatherResult.Success(jsonObj))
                
            } else {
                print("could not get json from file, make sure that file contains valid json.")
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            completionHandler(WeatherResult.Error(error.debugDescription))
        }
    }
    

    // MARK: Write JSON to File
    func writeToJsonFile(_ json:JSON,_ name:NSString)->Void
    {
        
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        print("Document Path:+ \(documentsDirectoryPathString)")

        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        
        let jsonFilePath = documentsDirectoryPath.appendingPathComponent(name as String)
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
