//
//  AddViewCotroller+Handler.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

extension EditViewController {
    func onChangeSleepStartTime(datepicker: UIDatePicker) {
        isEditStarted = true
        workingDream.startAt = datepicker.date
        print("onChangeSleepStartTime: \(workingDream)")
    }
    
    func onChangeSleepEndTime(datepicker: UIDatePicker) {
        isEditStarted = true
        workingDream.endAt = datepicker.date
        print("onChangeSleepEndTime: \(workingDream)")
    }
    
    func onChangeMemo(textView: UITextView) {
        isEditStarted = true
        workingDream.memo = textView.text ?? ""
        print("onChangeMemo: \(workingDream)")
        
        let pattern = #"\s+"# // whitespaces
        let regex = try! Regex(pattern)
        workingDream.tags = textView.text.split(separator: regex, omittingEmptySubsequences: true)
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
        workingDream.dreamClass = .init(rawValue: selectedIndex) ?? .auspicious
        print("onChangeClass: \(workingDream)")
    }
    
    var isLucidSegmentedList: [String] {
        ["자각하지 못함", "자각함"]
    }
    
    func onChangeLucidOrNot(segment: UISegmentedControl) {
        isEditStarted = true
        let selectedIndex = segment.selectedSegmentIndex
        workingDream.isLucid = selectedIndex == 1
        print("onChangeLucidOrNot: \(workingDream)")
    }
    
    @objc func onTappedSave() {
        print("onTappedSave: \(workingDream)")
        
        guard isEditStarted else { return }
        
        let savedDream = dreamRepository.save(workingDream)
        workingDream = Dream(startAt: Date.now, endAt: Date.now, memo: "", dreamClass: .auspicious, isLucid: false)
        tableView.reloadData()
        isEditStarted.toggle()
        
        if isInsertingNewDream {
            let storyboard = UIStoryboard(name: "DetailDreamView", bundle: nil)
            guard let detailViewController = storyboard.instantiateViewController(identifier: "DetailDreamViewController")
                    as? DetailDreamViewController else { return }
            detailViewController.dream = savedDream
            navigationController?.pushViewController(detailViewController, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
            
            guard let detailViewController = navigationController?.topViewController as? DetailDreamViewController else {
                return
            }
            
            detailViewController.dream = savedDream
            detailViewController.loadData()
        }
    }
}
