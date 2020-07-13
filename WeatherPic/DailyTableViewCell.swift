//
//  DailyTableViewCell.swift
//  WeatherPic
//
//  Created by Romain Francois on 08/07/2020.
//  Copyright © 2020 Romain Francois. All rights reserved.
//

import UIKit

class DailyTableViewCell: UITableViewCell {

    @IBOutlet weak var dailyImageView: UIImageView!
    @IBOutlet weak var dailyWeekdayLabel: UILabel!
    @IBOutlet weak var dailyHighLabel: UILabel!
    @IBOutlet weak var dailyLowLabel: UILabel!
    @IBOutlet weak var dailySummaryView: UITextView!
    
    var dailyWeather: DailyWeather! {
        didSet {
            dailyImageView.image = UIImage(named: dailyWeather.dailyIcon)
            dailyWeekdayLabel.text = dailyWeather.dailyWeekday
            dailyHighLabel.text = "\(dailyWeather.dailyHigh)°"
            dailyLowLabel.text = "\(dailyWeather.dailyLow)°"
            dailySummaryView.text = dailyWeather.dailySummary
        }
    }
    
}
