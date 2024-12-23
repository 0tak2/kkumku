//
//  Dream.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import Foundation

struct Dream {
    var startAt: Date
    var endAt: Date
    var memo: String
    var dreamClass: DreamClass
    var isLucid: Bool
    var custom: [String: String] = [:]
}
