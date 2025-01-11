//
//  Dream.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import Foundation

struct Dream: Hashable {
    var id = UUID()
    var startAt: Date
    var endAt: Date
    var memo: String
    var dreamClass: DreamClass
    var isLucid: Bool
    var tags: [String] = []
    var custom: [String: String] = [:]
}

struct DreamEncodable: Hashable, Encodable {
    var id = UUID()
    var startAt: Date
    var endAt: Date
    var memo: String
    var dreamClass: String
    var isLucid: Bool
    var tags: [String] = []
    var custom: [String: String] = [:]
    
    init(from model: Dream) {
        self.id = model.id
        self.startAt = model.startAt
        self.endAt = model.endAt
        self.memo = model.memo
        self.dreamClass = model.dreamClass.descriptionFull()
        self.isLucid = model.isLucid
        self.tags = model.tags
        self.custom = model.custom
    }
}
