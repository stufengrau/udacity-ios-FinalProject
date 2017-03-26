//
//  PublicationDate.swift
//  BookCase
//
//  Created by heike on 21/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation

struct PublicationDate: CustomStringConvertible {
    
    // MARK: - Properties
    var date: Date
    var dateType: DateType
    
    // Return a custom description for the different date types
    var description: String {
        let dateFormatter = DateFormatter()
        switch self.dateType {
        case .Year:
            dateFormatter.dateFormat = "yyyy"
        case .YearMonth:
            dateFormatter.dateFormat = "MMMM yyyy"
        case .YearMonthDay:
            dateFormatter.dateStyle = DateFormatter.Style.long
        }
        return dateFormatter.string(from: self.date)
    }
    
    // The dates returned by Google Books are ISO-formatted strings
    // and can contain only Year, Year and Month, or Year, Month and Day
    // How to iterate over an enumeration see http://stackoverflow.com/a/24137319
    enum DateType: String {
        case Year = "yyyy"
        case YearMonth = "yyyy-MM"
        case YearMonthDay = "yyyy-MM-dd"
        static let allValues = [Year, YearMonth, YearMonthDay]
    }
    
    static func from(isoDate: String?) -> PublicationDate?{
        guard let isoDate = isoDate else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        
        // Iterate over the different DateTypes and format
        // a Date from String with the proper date format
        for dateType in DateType.allValues {
            dateFormatter.dateFormat = dateType.rawValue
            if let date = dateFormatter.date(from: isoDate) {
                // If a date could be formatted, store values and return
                return PublicationDate(date: date, dateType: dateType)
            }
        }
        
        // No valid date present
        return nil
    }
    
}
