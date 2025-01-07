//
//  CalendarViewController.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {
    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: DataSource!
    var dreamCellRegistraion: UICollectionView.CellRegistration<UICollectionViewListCell, Item>!
    var labelCellRegistraion: UICollectionView.CellRegistration<UICollectionViewListCell, Item>!
    
    let dreamRepository: DreamRepository = DreamRepository.shared
    var dreamsForDay: [Date: [Dream]] = [:]
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "꿈 달력"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // MARK: - Calendar
        calendarView.delegate = self
        calendarView.dataSource = self
        
        // appearance
        calendarView.backgroundColor = .systemGray6
        calendarView.appearance.headerTitleColor = .primary
        calendarView.appearance.headerTitleFont = .systemFont(ofSize: 16, weight: .semibold)
        calendarView.appearance.weekdayTextColor = .primary
        calendarView.appearance.weekdayFont = .systemFont(ofSize: 16, weight: .semibold)
        
        calendarView.appearance.titleDefaultColor = .white
        calendarView.appearance.titleSelectionColor = .black
        calendarView.appearance.selectionColor = .primary
        
        calendarView.appearance.subtitleDefaultColor = .lightGray
        calendarView.appearance.subtitleSelectionColor = .darkGray
        
        // locale
        calendarView.locale = Locale(identifier: "ko_KR")
        calendarView.appearance.headerDateFormat = "YYYY년 MM월"
        calendarView.calendarWeekdayView.weekdayLabels[0].text = "일"
        calendarView.calendarWeekdayView.weekdayLabels[1].text = "월"
        calendarView.calendarWeekdayView.weekdayLabels[2].text = "화"
        calendarView.calendarWeekdayView.weekdayLabels[3].text = "수"
        calendarView.calendarWeekdayView.weekdayLabels[4].text = "목"
        calendarView.calendarWeekdayView.weekdayLabels[5].text = "금"
        calendarView.calendarWeekdayView.weekdayLabels[6].text = "토"
        
        // init
        calendarView.select(Date.now)
        
        // MARK: - CollectionView
        initCollectionView()
        loadDreamsOfCurrentMonth()
        displayDreams(of: Date.now)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadDreamsOfCurrentMonth()
        if let selectedDate = selectedDate {
            displayDreams(of: selectedDate)
        }
    }
    
    private func displayDreams(of date: Date) {
        if let normalizedDate = truncateHours(of: date) {
            let dreamsThatDay = dreamsForDay[normalizedDate] ?? []
            applySnapshot(dreams: dreamsThatDay)
            selectedDate = normalizedDate
        } else {
            applySnapshot(dreams: [])
        }
    }
    
    private func loadDreamsOfCurrentMonth() {
        // find dreams in this month
        let date = calendarView.currentPage
        Log.debug("will load dreams in \(date)")
        
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        
        guard let year = components.year, let month = components.month,
              let firstDay = Date.firstDayOfMonth(year: year, month: month),
              let lastDay = Date.lastDayOfMonth(year: year, month: month) else {
            
            Log.debug("선택된 월의 1일과 말일을 알 수 없습니다")
            return
        }
        
        let dreams = dreamRepository.findAll(from: firstDay, to: lastDay)
        
        // allocate to dreamsForDay
        self.dreamsForDay = dreams.reduce(into: [:]) { dict, dream in
            var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: dream.endAt)
            dateComponents.hour = 0
            dateComponents.minute = 0
            dateComponents.second = 0
            dateComponents.nanosecond = 0
            
            if let date = Calendar.current.date(from: dateComponents) {
                dict[date, default: []].append(dream)
            }
        }
    }
    
    private func truncateHours(of date: Date) -> Date? {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        
        return Calendar.current.date(from: dateComponents)
    }
}

extension CalendarViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        Log.debug("didSelet data \(date)")
        
        displayDreams(of: date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        loadDreamsOfCurrentMonth()
        calendar.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            guard let calendar = self?.calendarView else { return }
            
            calendar.select(calendar.currentPage) // 이번 달 1일로 선택
            self?.selectedDate = calendar.currentPage
            self?.displayDreams(of: calendar.currentPage)
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let shouldSelectDateComponents = Calendar.current.dateComponents([.month], from: date)
        let monthOfShouldSelect = shouldSelectDateComponents.month
        
        let currentDateComponents = Calendar.current.dateComponents([.month], from: calendar.currentPage)
        let monthOfCurrentPage = currentDateComponents.month
        
        return monthOfShouldSelect == monthOfCurrentPage // 이전달, 다음달 일자의 경우 선택되지 않음
    }
}

extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        if let date = truncateHours(of: date), let dreams = dreamsForDay[date], !dreams.isEmpty {
            return "●"
        } else {
            return nil
        }
    }
}
