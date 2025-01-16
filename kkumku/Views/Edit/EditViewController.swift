//
//  AddViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

class EditViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var isInsertingNewDream = true
    var workingDream: Dream = {
        let settings = UserSettings.shared
        let calendar = Calendar.current
        
        let bedTimeStrFallback = Date.fromHourAndMinute(hour: 22, minute: 00)!.toISOString()
        let bedTimeRaw = settings.string(.bedTime, or: bedTimeStrFallback)
        let userBedTime = Date.fromISOString(isoString: bedTimeRaw)!
        let (hour, minute) = (userBedTime.toHourAndMinute()[0], userBedTime.toHourAndMinute()[1])
        
        let bedTimeToShow: Date
        if let todayBedTime = Date.fromHourAndMinute(hour: hour, minute: minute) {
            if todayBedTime <= Date.now { // 오늘 일자의 취침 시각이 현재보다 과거라면 바로 적용
                bedTimeToShow = todayBedTime
            } else { // 오늘 일자의 취침 시간이 현재보다 미래라면 어제의 취침 시간을 적용
                let yesterDayBedTime = calendar.date(byAdding: .day, value: -1, to: todayBedTime)
                bedTimeToShow = yesterDayBedTime ?? Date.now
            }
        } else {
            bedTimeToShow = Date.now // 문제가 있다면 현재로 적용
        }
        
        return Dream(startAt: bedTimeToShow, endAt: Date.now, memo: "", dreamClass: .auspicious, isLucid: false)
    }()
    
    var isEditStarted: Bool = false {
        didSet {
            navigationItem.rightBarButtonItem?.tintColor = isEditStarted ? nil : .gray
        }
    }
    let dreamRepository = DreamRepository.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isInsertingNewDream {
            navigationItem.title = "새 꿈"
        } else {
            navigationItem.title = "수정하기"
        }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "저장", style: .done, target: self, action: #selector(onTappedSave))
        navigationItem.rightBarButtonItem?.tintColor = .gray
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func viewTapped() {
        view.endEditing(true)
    }
}
