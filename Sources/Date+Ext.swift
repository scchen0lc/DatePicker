//
//  Date+Ext.swift
//  
//
//  Created by 陳世爵 on 2021/10/18.
//

import Foundation

extension Date {
    
    var year: Int { Calendar.current.dateComponents([.year], from: self).year! }
    
    var month: Int { Calendar.current.dateComponents([.month], from: self).month! }
    
    var day: Int { Calendar.current.dateComponents([.day], from: self).day! }
    
    var weekday: String {
        var calendar = Calendar.current
        if let localeId = Locale.preferredLanguages.first {
            calendar.locale = Locale.init(identifier: localeId)
        }
        let index = Calendar.current.component(.weekday, from: self) - 1
        return calendar.shortWeekdaySymbols[index]
    }
    
    func offset(years: Int? = nil, months: Int? = nil, days: Int? = nil) -> Date? {
        let components = DateComponents(year: years, month: months, day: days)
        return Calendar.current.date(byAdding: components, to: self)
    }
    
}
