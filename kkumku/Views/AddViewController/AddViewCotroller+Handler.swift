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
        
        let pattern = #"\s+"# // whitespaces
        let regex = try! Regex(pattern)
        newDream.tags = textView.text.split(separator: regex, omittingEmptySubsequences: true)
            .filter { $0.starts(with: "#") && $0 != "#" }
            .map({ tag in
                let nextHashIndex = tag.index(tag.startIndex, offsetBy: 1)
                let hashOmitted = tag[nextHashIndex..<tag.endIndex]
                return String(hashOmitted)
            })
        updateTagSection()
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
        
        if isEditStarted {
            dreamRepository.insert(newDream)
            let savedDream = newDream
            newDream = Dream(startAt: Date.now, endAt: Date.now, memo: "", dreamClass: .auspicious, isLucid: false)
            tableView.reloadData()
            isEditStarted.toggle()
            
            let storyboard = UIStoryboard(name: "DetailDreamView", bundle: nil)
            guard let detailViewController = storyboard.instantiateViewController(identifier: "DetailDreamViewController")
                    as? DetailDreamViewController else { return }
            detailViewController.dream = savedDream
            navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}
