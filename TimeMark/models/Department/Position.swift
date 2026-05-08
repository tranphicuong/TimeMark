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

struct PositionActionData: Codable {
    let id: String
    let message: String
}

struct PositionActionResponse: Codable {
    let success: Bool
    let data: PositionActionData
}


struct DeletePositionResponse: Codable {
    let success: Bool
    let message: String
}
