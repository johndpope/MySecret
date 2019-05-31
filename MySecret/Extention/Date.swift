//
//  Date.swift
//  MySecret
//
//  Created by Amir lahav on 21/04/2019.
//  Copyright © 2019 la-labs. All rights reserved.
//

import Foundation

extension Date {
    
    func toString(dateStyle:DateFormatter.Style) -> String
    {
        let dateFormatter = DateFormatter()
  
        dateFormatter.dateStyle = dateStyle
        
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: self)

    }
    
    func toString(dateType:MSAssetCollectionSubtype) -> String
    {
        let dateFormatter = DateFormatter()
        
        switch dateType {
        case .monthMoment:
            dateFormatter.dateFormat = "LLLL yyyy"
        default:
            dateFormatter.dateFormat = "LLL d, yyyy"
        }
        
        return dateFormatter.string(from: self)
    }

    
    func toKeyString(dateType:DateType) -> String
    {
        let dateComponents = Calendar.current.dateComponents([.day,.month,.year], from: self)
        
        
        var dayStr = "00"
        var monthStr = "00"
        var yearStr = "0000"
        if let day = dateComponents.day {
            dayStr = day > 9 ? "\(day)" : "0\(day)"
        }
        
        if let month = dateComponents.month {
            monthStr = month > 9 ? "\(month)" : "0\(month)"
        }
        
        if let year = dateComponents.year {
            yearStr = "\(year)"
        }
        switch dateType {
        case .day:
            return yearStr + monthStr + dayStr
        case .month:
            return yearStr + monthStr
        case .year:
            return yearStr 
        }
    }
    
}

extension Date {

    var yearMonthDay: String {
        return DateHelper.formatterYYYYMMDD.string(from: self)
    }
    
    var month: String{
        return DateHelper.formatterYYYYMM.string(from: self)
    }
    
    var year: String {
        return DateHelper.formatterYYYY.string(from: self)
    }
}

struct DateHelper {
    static let formatterYYYYMMDD: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    static let formatterYYYY: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    static let formatterYYYYMM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMM"
        return formatter
    }()
}

enum DateType
{
    case day
    case month
    case year
}


extension Formatter {
    static let monthMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLL"
        return formatter
    }()
    static let hour12: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h"
        return formatter
    }()
    static let minute0x: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm"
        return formatter
    }()
    static let amPM: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a"
        return formatter
    }()
}
extension Date {
    var monthMedium: String  { return Formatter.monthMedium.string(from: self) }
    var hour12:  String      { return Formatter.hour12.string(from: self) }
    var minute0x: String     { return Formatter.minute0x.string(from: self) }
    var amPM: String         { return Formatter.amPM.string(from: self) }
}
