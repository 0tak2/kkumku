//
//  CalendarViewController+CollectionView.swift
//  kkumku
//
//  Created by 임영택 on 1/7/25.
//

import UIKit

extension CalendarViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    
    enum Section: Int {
        case main
    }
    
    enum Item: Hashable {
        case dreamCell(Dream)
        case labelCell(String)
    }
    
    func initCollectionView() {
        initLayout()
        registerCells()
        setDataSource()
        
        collectionView.delegate = self
    }
    
    private func initLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        collectionView.collectionViewLayout = layout
    }
    
    private func registerCells() {
        dreamCellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            if case let .dreamCell(dream) = item {
                var content = cell.defaultContentConfiguration()
                content.text = "\(dream.memo)"
                content.textProperties.numberOfLines = 3
                content.secondaryText = "\(dream.dreamClass.descriptionEmoji()) \(dream.startAt.localizedString) ~ \(dream.endAt.localizedStringNoYear)"

                cell.contentConfiguration = content
                cell.contentView.backgroundColor = .systemGray6
            }
        }
        
        labelCellRegistraion = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            if case let .labelCell(labelText) = item {
                var content = cell.defaultContentConfiguration()
                content.text = labelText
                cell.contentConfiguration = content
            }
        }
    }
    
    private func setDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            guard let dreamCellRegistraion = self?.dreamCellRegistraion,
                  let labelCellRegistraion = self?.labelCellRegistraion else {
                return UICollectionViewCell()
            }
            
            if case .dreamCell = item {
                return collectionView.dequeueConfiguredReusableCell(using: dreamCellRegistraion, for: indexPath, item: item)
            }
            
            if case .labelCell = item {
                return collectionView.dequeueConfiguredReusableCell(using: labelCellRegistraion, for: indexPath, item: item)
            }
            
            return UICollectionViewCell()
        })
    }
    
    func applySnapshot(dreams: [Dream]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        
        if !dreams.isEmpty {
            let items: [Item] = dreams.map { dream in
                Item.dreamCell(dream)
            }
            
            snapshot.appendItems(items, toSection: .main)
        } else {
            snapshot.appendItems([.labelCell("저장된 꿈이 없습니다.")], toSection: .main)
        }
        
        dataSource.apply(snapshot)
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
