//
//  Weather.swift
//  FinalWeather
//
//  Created by JingJing HAO on 12/7/16.
//  Copyright © 2016 JingJing. All rights reserved.
//

import Foundation

struct Weather {
    var city: String
    var temperature: String
    var pressure :Double
    var humidity :Int
    var windSpeed:Double
    var weatherDes:String

    init(json:JSON){
        let tempDegrees  = json["main"]["temp"].double
        self.temperature = String(format: "%.0f", tempDegrees!)
        self.city        = json["name"].string!
        self.pressure    = json["main"]["pressure"].double!
        self.humidity    = json["main"]["humidity"].int!
        self.windSpeed   = json["wind"]["speed"].double!
        self.weatherDes  = json["weather"][0]["main"].string!
    }
}

