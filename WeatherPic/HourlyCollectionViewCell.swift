//
//  HourlyCollectionViewCell.swift
//  WeatherPic
//
//  Created by Romain Francois on 10/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hourlyLabel: UILabel!
    @IBOutlet weak var hourlyTemp: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    var hourlyWeather: HourlyWeather! {
        didSet {
            hourlyLabel.text = hourlyWeather.hour
            hourlyTemp.text = "\(hourlyWeather.hourlyTemperature)°"
            iconImageView.image = UIImage(systemName: hourlyWeather.hourlyIcon)
        }
    }
}
