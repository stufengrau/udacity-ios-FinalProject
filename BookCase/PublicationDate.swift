//
//  PublicationDate.swift
//  BookCase
//
//  Created by heike on 21/03/2017.
//  Copyright © 2017 stufengrau. All rights reserved.
//

import Foundation

struct PublicationDate: CustomStringConvertible {
    
    var date: Date
    private var dateType: DateType
    
    // http://stackoverflow.com/a/24137319
    private enum DateType: String {
        case Year = "yyyy"
        case YearMonth = "yyyy-MM"
        case YearMonthDay = "yyyy-MM-dd"
        static let allValues = [Year, YearMonth, YearMonthDay]
    }

    init?(isoDate: String?) {
        
        guard let isoDate = isoDate else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        
        for dateType in DateType.allValues {
            dateFormatter.dateFormat = dateType.rawValue
            if let date = dateFormatter.date(from: isoDate) {
                self.date = date
                self.dateType = dateType
                return
            }
        }
        
        return nil
        
    }
    
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
    
}
