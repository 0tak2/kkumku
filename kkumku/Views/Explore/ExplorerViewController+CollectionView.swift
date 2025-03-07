//
//  ExplorerViewController+CollectionView.swift
//  kkumku
//
//  Created by 임영택 on 12/26/24.
//

import UIKit

extension ExploreViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    
    enum Section: Int {
        case controls
        case main
        case info
    }
    
    enum Item: Hashable {
        case sortButton(SortAction)
        case dreamCard(Dream)
        case label(String)
    }
    
    enum SortAction {
        case ascend
        case descend
        
        func description() -> String {
            switch self {
            case .ascend:
                return "과거순"
            case .descend:
                return "최근순"
            }
        }
    }
    
    func setDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            guard let sortButtonCellRegistration = self?.sortButtonCellRegistration,
                  let infoLabelCellRegistration = self?.infoLabelCellRegistration else {
                      
                return UICollectionViewCell()
            }
            
            switch item {
            case .sortButton:
                let cell = collectionView.dequeueConfiguredReusableCell(using: sortButtonCellRegistration, for: indexPath, item: item)
                return cell
            case .dreamCard(let dream):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DreamCollectionViewCell", for: indexPath)
                        as? DreamCollectionViewCell else { return UICollectionViewCell() }
                cell.configure(dream: dream)
                return cell
            case .label(_):
                let cell = collectionView.dequeueConfiguredReusableCell(using: infoLabelCellRegistration, for: indexPath, item: item)
                return cell
            }
        })
    }
    
    func registerCells() {
        sortButtonCellRegistration = UICollectionView.CellRegistration<SortButtonCollectionViewCell, Item> { [weak self] cell, _, item in
            if case let .sortButton(action) = item {
                let title = action.description()
                let isSelected: Bool
                let onTappedHandler: () -> Void
                switch action {
                case .descend:
                    // 최신부터
                    self?.toggleRecentButton = cell.getToggler()
                    
                    isSelected = !(self?.isAscending ?? false)
                    
                    onTappedHandler = { [weak self] in
                        self?.isAscending = false
                        
                        self?.toggleRecentButton?(true)
                        self?.toggleOldestButton?(false)
                        
                        self?.reloadData()
                    }
                case .ascend:
                    // 과거부터
                    self?.toggleOldestButton = cell.getToggler()
                    
                    isSelected = (self?.isAscending ?? false)
                    
                    onTappedHandler = { [weak self] in
                        self?.isAscending = true
                        
                        self?.toggleRecentButton?(false)
                        self?.toggleOldestButton?(true)
                        
                        self?.reloadData()
                    }
                }
                
                
                cell.configure(title: title, isSelected: isSelected, do: onTappedHandler )
            }
        }
        
        infoLabelCellRegistration = UICollectionView.CellRegistration(handler: { cell, indexPath, item in
            var contentConfiguration = cell.defaultContentConfiguration()
            
            if case .label(let labelText) = item {
                contentConfiguration.text = labelText
                contentConfiguration.textProperties.alignment = .center
            }
            
            cell.contentConfiguration = contentConfiguration
        })
    }
    
    func setLayout() -> UICollectionViewCompositionalLayout {
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let sectionKind = Section(rawValue: sectionIndex)
            
            if sectionKind == .controls {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(60), heightDimension: .absolute(32))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                return section
            }
            
            if sectionKind == .main {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(300))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 8
                return section
            }
            
            if sectionKind == .info {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(96))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
            
            return nil
        }
        
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
    
    private func applyDataSource(_ dreams: [Dream]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        snapshot.appendSections([.controls, .main, .info])
        
        // contorls
        snapshot.appendItems([.sortButton(.descend), .sortButton(.ascend)], toSection: .controls)
        
        // main
        let dreamItems = dreams.map { dream in
            Item.dreamCard(dream)
        }
        
        snapshot.appendItems(dreamItems, toSection: .main)
        
        // info
        if dreams.isEmpty {
            snapshot.appendItems([.label("아직 꿈이 없습니다.\n꿈을 기록하려면 + 버튼을 누르세요.")], toSection: .info)
        }
        
        dataSource.apply(snapshot)
    }
    
    func loadCurrentData() {
        let loaded = dreamRepository.fetchAll(sortBy: \DreamEntity.endAt, ascending: isAscending, numberOfItems: numberOfItems, page: page)
        applyDataSource(loaded)
    }
    
    func reloadData() {
        page = 1
        pageEnded = false
        loadCurrentData()
        collectionView.contentOffset.y = 0
    }
    
    func appendMoreData() {
        guard !pageEnded else { return }
        
        page += 1
        let moreData = dreamRepository.fetchAll(sortBy: \DreamEntity.endAt, ascending: isAscending, numberOfItems: numberOfItems, page: page)
        
        var snapshot = dataSource.snapshot()
        snapshot.appendItems(moreData.map({ Item.dreamCard($0) }), toSection: .main)
        
        if moreData.count < numberOfItems {
            snapshot.appendItems([.label("모든 꿈을 불러왔습니다.")], toSection: .info)
            pageEnded.toggle()
        }
        
        dataSource.apply(snapshot)
    }
}

extension ExploreViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.height > scrollView.frame.size.height else { return }
        
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            Log.debug("load more")
            appendMoreData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section),
              section == .main else { return }
        
        let index = indexPath.item
        let loadedDreams = self.dataSource.snapshot()
            .itemIdentifiers(inSection: .main)
            .compactMap { row in
                switch row {
                case .dreamCard(let dream):
                    return dream
                default:
                    return nil
                }
            }
        
        presentDetailView(for: loadedDreams[index], animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let section = Section(rawValue: indexPath.section)
        return section != .info
    }
}
