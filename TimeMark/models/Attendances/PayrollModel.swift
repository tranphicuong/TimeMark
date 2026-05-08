//
//  PayrollModel.swift
//  TimeMark
//
//  Created by Doanh on 5/8/26.
//

// Models/PayrollModel.swift

import Foundation

struct PayrollExportRequest {
    let year: Int
    let month: Int
    
    var monthParam: String {
        String(format: "%04d-%02d", year, month)
    }
}

struct PayrollExportResponse {
    let fileURL: URL
    let filename: String
}
