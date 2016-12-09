//
//  Forecast.swift
//  FinalWeather
//
//  Created by JingJing HAO on 12/7/16.
//  Copyright © 2016 JingJing. All rights reserved.
//

import Foundation
import UIKit


struct Forecast {
    var dateTime:String
    var tempsMin:String
    var tempsMax:String
    var weatherDes:String
    var pressure :Double
    var humidity :Int
    var windSpeed:Double
    var windDeg: Int

    init(_ dateValue:Double, _ tempDegreeMin:Double, _ tempDegreeMax:Double,_ weatherDes:String,_ pressure:Double,_ humidity:Int,_ windSpeed:Double,_ windDeg:Int){
        self.dateTime    = dateValue.convertTimeToString()
        self.tempsMin    = String(format: "%.0f", tempDegreeMin)
        self.tempsMax    = String(format: "%.0f", tempDegreeMax)
        self.weatherDes  = weatherDes
        self.pressure    = pressure
        self.humidity    = humidity
        self.windSpeed   = windSpeed
        self.windDeg     = windDeg
    }
   
    
}
