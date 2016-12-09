//
//  WeatherManager.swift
//  FinalWeather
//
//  Created by JingJing HAO on 12/8/16.
//  Copyright © 2016 JingJing. All rights reserved.
//

import Foundation
import Alamofire

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
    
    private var params = [String : AnyObject]()
    public init(apiKey: String) {
        params["APPID"] = apiKey as AnyObject?
    }
    
    private func apiCall(method: Router, response: (WeatherResult) -> Void) {
        Alamofire.request(method).responseJSON { response in
//            guard let js: AnyObject = data.value , data.isSuccess else {
//                response(WeatherResult.Error(data.error.debugDescription))
//                return
//            }
//            response(WeatherResult.Success(JSON(js)))
            print("error \(response.result.error)")
            print("value \(response.result.value)")
            switch response.result {
            case .Success(let data):
                response(WeatherResult.Success(JSON(data.value)))
//                completion?(error: nil, data: data)
//                let json = JSON(data)
//                let keychain = Keychain()
//                if (keychain["deviceId"] == nil)
//                {
//                    if json["uuid"] != nil{
//                        keychain["deviceId"] = json["uuid"].stringValue
//                    }
//                }
            case .Failure(let error):
                completion?(error: error, data: nil)
                print("Request failed with error: \(error)")
            }
        }
//        Alamofire.request(method).responseJSON { (_, _, data) in
//            guard let js: AnyObject = data.value where data.isSuccess else {
//                response(WeatherResult.Error(data.error.debugDescription))
//                return
//            }
//            response(WeatherResult.Success(JSON(js)))
//        }
    }

    enum Router: URLRequestConvertible {
        static let baseURLString = "http://api.openweathermap.org/data/"
        static let apiVersion = "2.5"
        
        case Weather([String: AnyObject])
        case DailyForecast([String: AnyObject])
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            switch self {
            case .Weather:
                return "/weather"
            case .DailyForecast:
                return "/forecast/daily"
        
            }
        }
        
        // MARK: URLRequestConvertible
        var URLRequest: NSMutableURLRequest {
            let URL = NSURL(string: Router.baseURLString + Router.apiVersion)!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path)!)
            mutableURLRequest.HTTPMethod = method.rawValue
            
            func encode(params: [String: AnyObject]) -> NSMutableURLRequest {
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
            }
            
            switch self {
            case .Weather(let parameters):
                return encode(parameters)
            case .DailyForecast(let parameters):
                return encode(parameters)
            }
        }
    }
    

}
