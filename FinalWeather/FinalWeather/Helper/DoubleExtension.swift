//
//  DoubleExtension.swift
//  FinalWeather
//
//  Created by JingJing HAO on 12/8/16.
//  Copyright © 2016 JingJing. All rights reserved.
//

import Foundation

extension Double {
    func convertTimeToString() -> String{
        let currentDateTime = NSDate(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d"
        return dateFormatter.string(from: currentDateTime as Date)
    }
}

