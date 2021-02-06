//
//  CalendarData.swift
//  theBudget
//
//  Created by Sergey Neupokoev on 15/01/2021.
//

import Foundation


enum Month {
    case Jan
    case Feb
    case Mar
    case Apr
    case May
    case Jun
    case Jul
    case Aug
    case Sep
    case Oct
    case Nov
    case Dec
    
    var monthTitle: String {
        switch self {
        case .Jan:            return "JAN"
        case .Feb:           return "FEB"
        case .Mar:              return "MAR"
        case .Apr:              return "APR"
        case .May:                return "MAY"
        case .Jun:               return "JUN"
        case .Jul:               return "JUL"
        case .Aug:             return "AUG"
        case .Sep:          return "SEP"
        case .Oct:            return "OCT"
        case .Nov:           return "NOV"
        case .Dec:           return "DEC"
        }
    }
}



extension Date {
    func xDays(_ x: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: x, to: self)!
    }
    func xWeeks(_ x: Int) -> Date {
        return Calendar.current.date(byAdding: .weekOfYear, value: x, to: self)!
    }
    var weeksHoursFromToday: DateComponents {
        return Calendar.current.dateComponents( [.weekOfYear, .hour], from: self, to: Date())
    }
}

class CalendarService {
    
    static let instance = CalendarService()
    var currentDateIndex: Int = 0
    
    func getDates() -> [String] {
        
        var arrayOfFormattedDates = [String]()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM\ndd\nE"
        
        var dateStartingIndex = -30
        while dateStartingIndex != 30 {
            dateStartingIndex += 1
            arrayOfFormattedDates.append(formatter.string(from: Date().xDays(dateStartingIndex)))
        }
        currentDateIndex = find(value: formatter.string(from: Date()), in: arrayOfFormattedDates)!
        return arrayOfFormattedDates
    }
    
    func datesForCoreData() -> [String] {
        
        var arrayOfDatesForCoreData = [String]()
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
        var dateStartingIndex = -30
        while dateStartingIndex != 30 {
            dateStartingIndex += 1
            arrayOfDatesForCoreData.append(formatter.string(from: Date().xDays(dateStartingIndex)))
        }
        currentDateIndex = find(value: formatter.string(from: Date()), in: arrayOfDatesForCoreData)!
        return arrayOfDatesForCoreData
    }
    
    func find(value searchValue: String, in array: [String]) -> Int?
    {
        for (index, value) in array.enumerated()
        {
            if value == searchValue {
                return index
            }
        }
        return nil
    }

}
