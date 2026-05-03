//
//  TimesTamp.swift
//  TimeMark
//
//  Created by Rebel on 4/29/26.
//
import Foundation

extension FirestoreTimestamp {
    var toDate: Date {
        Date(timeIntervalSince1970: TimeInterval(_seconds))
    }

    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: toDate)
    }
}
