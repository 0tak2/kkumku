//
//  DreamClass.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import Foundation

enum DreamClass: Int {
    case auspicious
    case ominous
    case ambiguous
    
    func descriptionEmoji() -> String {
        switch self {
        case .auspicious: "😀"
        case .ominous: "😱"
        case .ambiguous: "😶"
        }
    }
    
    func descriptionFull() -> String {
        switch self {
        case .auspicious: "😀 길몽"
        case .ominous: "😱 악몽"
        case .ambiguous: "😶 보통"
        }
    }
}
