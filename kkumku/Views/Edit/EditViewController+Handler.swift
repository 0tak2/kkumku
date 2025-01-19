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
        Log.debug("onChangeSleepStartTime: \(workingDream)")
    }
    
    func onChangeSleepEndTime(datepicker: UIDatePicker) {
        isEditStarted = true
        workingDream.endAt = datepicker.date
        Log.debug("onChangeSleepEndTime: \(workingDream)")
    }
    
    func onChangeMemo(textView: UITextView) {
        isEditStarted = true
        workingDream.memo = textView.text ?? ""
        Log.debug("onChangeMemo: \(workingDream)")
        
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
        Log.debug("onChangeClass: \(workingDream)")
    }
    
    var isLucidSegmentedList: [String] {
        ["자각하지 못함", "자각함"]
    }
    
    func onChangeLucidOrNot(segment: UISegmentedControl) {
        isEditStarted = true
        let selectedIndex = segment.selectedSegmentIndex
        workingDream.isLucid = selectedIndex == 1
        Log.debug("onChangeLucidOrNot: \(workingDream)")
    }
    
    func saveWorkingDream() {
        guard isEditStarted else { return }
        
        // MARK: Save a dream to Core Data
        let savedDream = dreamRepository.save(workingDream)
        guard let savedDream = savedDream else {
            Log.info("꿈 저장을 시도했으나 저장에 실패한 것 같습니다. workingDream \(workingDream)")
            return
        }
        
        // MARK: Update UI
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            // 다른 뷰로 이동 완료된 후에 초기화
            // 탭바 스위칭이 된다고 해서 self가 deinit 되지는 않음
            // see: https://stackoverflow.com/a/52121549
            self?.workingDream = Dream()
            self?.tableView.reloadData()
            self?.isEditStarted.toggle()
        }
        
        if isInsertingNewDream {
            let exploreViewIndex = 2
            
            if let tabBarController = tabBarController,
               let viewControllers = tabBarController.viewControllers,
               let exploreNavViewController = viewControllers[exploreViewIndex] as? UINavigationController,
               let exploreViewController = exploreNavViewController.viewControllers.first as? ExploreViewController {
                exploreNavViewController.popToRootViewController(animated: false) // 스택의 모든 뷰 비우기
                tabBarController.selectedIndex = exploreViewIndex // 탭바 스위칭
                exploreViewController.presentDetailView(for: savedDream, animated: false) // 여기서 DetailView 띄우기
            }
        } else {
            navigationController?.popViewController(animated: true)
            
            guard let detailViewController = navigationController?.topViewController as? DetailDreamViewController else {
                return
            }
            
            detailViewController.dream = savedDream
            detailViewController.loadData()
        }
    }
    
    @objc func onTappedSave() {
        Log.debug("onTappedSave: \(workingDream)")
        saveWorkingDream()
    }
}
