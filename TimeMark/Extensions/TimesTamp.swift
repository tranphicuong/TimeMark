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
struct FirebaseTimestamp: Decodable {
    let _seconds: Int
    let _nanoseconds: Int

    var date: Date {
        Date(timeIntervalSince1970: TimeInterval(_seconds))
    }
}
extension String {
    var lastTwoWords: String {
        let words = self.trimmingCharacters(in: .whitespaces)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
        if words.count >= 2 {
            return words.suffix(2).joined(separator: " ")
        }
        return self
    }
}
