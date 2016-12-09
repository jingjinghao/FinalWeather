//
//  ForecastTableViewCell.swift
//  FinalWeather
//
//  Created by JingJing HAO on 12/9/16.
//  Copyright © 2016 JingJing. All rights reserved.
//

import Foundation
import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblInfoLeft: UILabel!
    @IBOutlet weak var lblInfoRight: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadCell(_ forecast:Forecast) {
        
        let attrs1 = [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 30), NSForegroundColorAttributeName : UIColor.white]
        
        let attrs2 = [NSFontAttributeName : UIFont.systemFont(ofSize:16), NSForegroundColorAttributeName : UIColor.white]
        
        let attributedString1 = NSMutableAttributedString(string:"\(forecast.dateTime)\n", attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string:"\(forecast.tempsMin)°\t \(forecast.tempsMax)° \n\(forecast.weatherDes)", attributes:attrs2)
        
        let combination = NSMutableAttributedString()
        
        combination.append(attributedString1)
        combination.append(attributedString2)
         self.lblInfoLeft.attributedText = combination
        
        let windSpeed   = String(format: "%.0.2f", forecast.windSpeed)
        self.lblInfoRight.text = "Pressure:\t\(forecast.pressure) hpa\nHumidity:\t\(forecast.humidity)%\nWind:\t\(windSpeed)m/s"
    }

}
