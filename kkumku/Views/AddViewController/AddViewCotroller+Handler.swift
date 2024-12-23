//
//  AddViewCotroller+Handler.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

extension AddViewController {
    func onChangeSleepStartTime(datepicker: UIDatePicker) {
        isEditStarted = true
        newDream.startAt = datepicker.date
        print("onChangeSleepStartTime: \(newDream)")
    }
    
    func onChangeSleepEndTime(datepicker: UIDatePicker) {
        isEditStarted = true
        newDream.endAt = datepicker.date
        print("onChangeSleepEndTime: \(newDream)")
    }
    
    func onChangeMemo(textView: UITextView) {
        isEditStarted = true
        newDream.memo = textView.text ?? ""
        print("onChangeMemo: \(newDream)")
    }
    
    var dreamClassSegmentedList: [String] {
        ["길몽", "악몽", "보통"]
    }
    
    func onChangeClass(segment: UISegmentedControl) {
        isEditStarted = true
        let selectedIndex = segment.selectedSegmentIndex
        newDream.dreamClass = .init(rawValue: selectedIndex) ?? .auspicious
        print("onChangeClass: \(newDream)")
    }
    
    var isLucidSegmentedList: [String] {
        ["자각하지 못함", "자각함"]
    }
    
    func onChangeLucidOrNot(segment: UISegmentedControl) {
        isEditStarted = true
        let selectedIndex = segment.selectedSegmentIndex
        newDream.isLucid = selectedIndex == 1
        print("onChangeLucidOrNot: \(newDream)")
    }
    
    @objc func onTappedSave() {
        print("onTappedSave: \(newDream)")
    }
}
