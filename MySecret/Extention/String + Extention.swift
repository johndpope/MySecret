//
//  ExtentionString.swift
//  MySecret
//
//  Created by amir lahav on 8.10.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import Foundation
import UIKit
import DifferenceKit
extension String:Differentiable {
    
    static func random(length: Int = 16) -> String {
        
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: String.IndexDistance(randomValue))])"
        }
        return randomString
    }
    

    static func getHeaderSubtitle(date:String, country:String) -> String
    {
        return "\(date)  \u{00B7}  \(country)"
    }
    
    
    func containsIgnoreCase(_ string: String) -> Bool {
        return self.lowercased().contains(string.lowercased())
    }
    
        func startsWith(string: String) -> Bool {
            guard let range = range(of: string, options:[.anchored,.caseInsensitive]) else {
                return false
            }
            return range.lowerBound == startIndex
        }
    
        func caseInsensitiveHasPrefix(_ prefix: String) -> Bool {
            return lowercased().hasPrefix(prefix.lowercased())
        }
    

    
    
    static func getWeekday(date:Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier: "en")
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
        
    }
    
    static func getShortDate(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.short
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func getYearDate(date:Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyy")
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func getMonthDate(date:Date) -> String
    {
        let today = Date()
        let calendar = Calendar.init(identifier: .gregorian)
        let year = calendar.component(.year, from: today)
        let dateYear = calendar.component(.year, from: date)
        let isEqual = year == dateYear
        let dateFormatter = DateFormatter()
        

            switch isEqual {
            case true:
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM")
            default:
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMM, yyyy")
            }
            
            let convertedDate = dateFormatter.string(from: date)
            return convertedDate
        
    }
    
    static func getDateString(date: Date) -> String
    {
        let today = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: today)
        let dateYear = calendar.component(.year, from: date)
        let isEqual = year == dateYear
        let dateFormatter = DateFormatter()

        switch isEqual {
        case true:
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMMd")
        default:
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = DateFormatter.Style.long
        }

        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func getTimeFromDateString(date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        dateFormatter.timeStyle = DateFormatter.Style.short
        let convertedDate = dateFormatter.string(from: date)
        return convertedDate
    }
    
    static func convertStringToDate(string:String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return dateFormatter.date(from:string)!
        
        
        
        //        dateFormatter.dateStyle = DateFormatter.Style.short //Your date format
        //        let date = dateFormatter.date(from: string)
        //        return date!
        
    }
    
    static  func stringFromTimeInterval(interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        if interval >= 3600 {
            formatter.allowedUnits.insert(.hour)
        }
        
        return formatter.string(from: interval)!
    }
    
    static func photoCountToString(count: Int) -> String
    {
        switch count == 1 {
        case true: return "1 Asset"
        default: return "\(count) Assets"
        }
    }
}