//
//  TweetIndex.swift
//  PeekInternDemo
//
//  Created by Rohin Bhushan on 3/19/16.
//  Copyright © 2016 rohinbhushan. All rights reserved.
//

import Foundation

// takes JSON Dictionary and stores desired info
struct TweetIndex
{
    var currentTime: String?
    var temperature: Int
    var humidity: Double
    var precipProbability: Double
    var summary: String

    var windSpeed: Int
    
    init(weatherDictionary: NSDictionary)
    {
        let currentWeather = weatherDictionary["currently"] as!NSDictionary
        temperature = currentWeather["temperature"] as! Int
        humidity = currentWeather["humidity"] as! Double
        windSpeed = currentWeather["windSpeed"] as! Int
        precipProbability = currentWeather["precipProbability"] as! Double
        summary = currentWeather["summary"] as! String
    }
}
