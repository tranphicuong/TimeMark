//
//  Position.swift
//  TimeMark
//
//  Created by Rebel on Doanh.
//


struct Position : Identifiable,  Codable, Hashable{
    let id: String
    let name: String
    let description: String?
    let isDeleted : Bool?
}
struct PositionListResponse: Codable {
    let success: Bool
    let data: [Position]
}

