//
//  ViewController.swift
//  FinalWeather
//
//  Created by JingJing HAO on 12/6/16.
//  Copyright © 2016 JingJing. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Attribut
    let weatherManager = WeatherManager()
    let city = "lyon"
    fileprivate let currentWeatherJsonFileName       = "currentweather.json"
    fileprivate let forecastsJsonFileName            = "forecast.json"

    @IBOutlet weak var lblcityName: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var lblWeatherDescriptionLeft: UILabel!
    @IBOutlet weak var lblWeatherDescriptionRight: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!

    var currentWeather: Weather? {
        didSet {
            self.lblcityName.text = currentWeather?.city
            self.lblTemperature.text = "\(currentWeather!.temperature)°"
            self.lblWeatherDescriptionLeft.text = "Pressure:\t\(currentWeather!.pressure)hpa\n\nHumidity:\t\(currentWeather!.humidity)%"
            let windSpeed   = String(format: "%.0.2f", currentWeather!.windSpeed)
            self.lblWeatherDescriptionRight.text = "\(currentWeather!.weatherDes)\n\nWind:\t\(windSpeed) m/s"
            SwiftSpinner.hide()
        }
    }
    
    var forecasts = [Forecast]() {
        didSet {
            self.forecastTableView.reloadData()
        }
    }

    // MARK: View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load data for display
        self.loadData()
    }
    
    // MARK: - Load Data
 
    func loadData() {
        let documentsDirectoryPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let documentsDirectoryPath = URL(string: documentsDirectoryPathString)!
        
        let jsonFilePathCurrent = documentsDirectoryPath.appendingPathComponent(currentWeatherJsonFileName)
        let jsonFilePathForecast = documentsDirectoryPath.appendingPathComponent(forecastsJsonFileName)

        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // if current weather json file exist
        if fileManager.fileExists(atPath: jsonFilePathCurrent.absoluteString, isDirectory: &isDirectory)
        {
            weatherManager.loadJson(jsonFilePathCurrent.absoluteString, completionHandler: { (WeatherResult) in
                switch WeatherResult {
                case .Success(let json):
                    self.currentWeather = Weather(json: json)
                    break
                case .Error(let errorMessage):
                    print("currentWeather error:\(errorMessage)")
                    break
                }
            })
        }
        else{
            DispatchQueue.main.async(execute: {
                SwiftSpinner.show("Connecting to satellite...")
            })
        }
        
        // if Forecast weather json file exist
        if fileManager.fileExists(atPath: jsonFilePathForecast.absoluteString, isDirectory: &isDirectory)
        {
            weatherManager.loadJson(jsonFilePathForecast.absoluteString, completionHandler: { (WeatherResult) in
                switch WeatherResult {
                case .Success(let json):
                    self.forecasts = self.weatherManager.getForecasts(json)
                    break
                case .Error(let errorMessage):
                    print("forecasts error:\(errorMessage)")
                    break
                }
            })
        }

        // Get current weather
        weatherManager.currentWeatherWithCityName(city) { (WeatherResult) in
            switch WeatherResult {
            case .Success(let json):
            self.weatherManager.writeToJsonFile(json, self.currentWeatherJsonFileName as NSString)

            DispatchQueue.main.async(execute: {
                    self.currentWeather = Weather(json: json)

            })
            break
            case .Error(let errorMessage):
                print("currentWeather error:\(errorMessage)")
                DispatchQueue.main.async(execute: {
                    SwiftSpinner.show("Ooops! Can not get current Weather").addTapHandler({
                            SwiftSpinner.hide()
                        })
                })
                break
            }
        }

        // Get daily forest weather
        weatherManager.dailyForecastWithCityName(city) { (WeatherResult) in
            switch WeatherResult {
            case .Success(let json):
                self.weatherManager.writeToJsonFile(json, self.forecastsJsonFileName as NSString)
                    DispatchQueue.main.async(execute: {
                        self.forecasts = self.weatherManager.getForecasts(json)
                    })
                    break
                case .Error(let errorMessage):
                    print("dailyForecastWithCityName error:\(errorMessage)")
                    DispatchQueue.main.async(execute: {
                        SwiftSpinner.show("Ooops! Can not get Forecast Weather").addTapHandler({
                            SwiftSpinner.hide()
                        })
                    })
                    break
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



// MARK: - UITableViewDataSource

extension ViewController:UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let forecast = forecasts[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell", for: indexPath) as! ForecastTableViewCell
        cell.loadCell(forecast)

        return cell
    }

}

