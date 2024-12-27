//
//  AddViewController+Section.swift
//  kkumku
//
//  Created by 임영택 on 12/23/24.
//

import UIKit

extension EditViewController {
    enum Section: Int, Hashable {
        case time
        case memo
        case select
        case tag
        case customField
    }
    
    enum Row: Hashable {
        case labelOnly(String)
        case startTimeDetePicker
        case endTimeDatePicker
        case memoTextView
        case dreamClassSegmentedControl
        case isLucidSegmentedControl
    }
}

extension EditViewController: UITableViewDelegate {
    
}

extension EditViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section(rawValue: section)
        
        switch section {
        case .time:
            return 2
        case .memo:
            return 1
        case .select:
            return 2
        case .tag:
            return 1
        case .customField:
            // return 1
            return 0
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = Section(rawValue: section)
        
        switch section {
        case .tag:
            return "태그"
//        case .customField:
//            return "커스텀 필드"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = Section(rawValue: section)
        
        switch section {
        case .tag:
            return "태그는 본문에 \"#태그\" 형식으로 입력하면 추가할 수 있어요"
//        case .customField:
//            return "설정에서 커스텀 필드 목록을 미리 정할 수 있어요"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let controls: [Section: [Row]] = [
            .time: [.startTimeDetePicker, .endTimeDatePicker],
            .memo: [.memoTextView],
            .select: [.dreamClassSegmentedControl, .isLucidSegmentedControl],
            .tag: [.labelOnly(workingDream.tags.isEmpty ? "지정된 태그가 없습니다." : workingDream.tags.joined(separator: ", "))],
//            .customField: [.labelOnly("테스트")],
        ]
        
        guard let section = Section(rawValue: indexPath.section), let rows = controls[section] else {
            return UITableViewCell()
        }
        
        let row = rows[indexPath.row]
        switch row {
        case .startTimeDetePicker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DateInputTableViewCell")
                as? DateInputTableViewCell {
                cell.configure("취침 시각", onChange: onChangeSleepStartTime)
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()
        case .endTimeDatePicker:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DateInputTableViewCell")
                as? DateInputTableViewCell {
                cell.configure("기상 시각", onChange: onChangeSleepEndTime)
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()
        case .memoTextView:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TextViewTableViewCell")
                as? TextViewTableViewCell {
                cell.configure("무슨 일이 있었나요?", onChange: onChangeMemo)
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()
        case .dreamClassSegmentedControl:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectInputTableViewCell")
                as? SelectInputTableViewCell {
                cell.configure("분류", choices: dreamClassSegmentedList, onChange: onChangeClass)
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()
        case .isLucidSegmentedControl:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectInputTableViewCell")
                as? SelectInputTableViewCell {
                cell.configure("자각몽", choices: isLucidSegmentedList, onChange: onChangeLucidOrNot)
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()
        case .labelOnly(let labelText):
            if let cell = tableView.dequeueReusableCell(withIdentifier: "LabelOnlyTableViewCell")
                as? LabelOnlyTableViewCell {
                cell.configure(labelText)
                cell.selectionStyle = .none
                return cell
            }
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = Section(rawValue: indexPath.section)
        
        switch section {
        case .memo: return 480
        default: return 36
        }
    }
}

extension EditViewController {
    func updateTagSection() {
        tableView.reloadSections(IndexSet(Section.tag.rawValue...Section.tag.rawValue), with: .automatic)
    }
}
