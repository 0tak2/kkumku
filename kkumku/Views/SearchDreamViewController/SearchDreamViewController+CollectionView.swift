//
//  SearchDreamViewController+CollectionView.swift
//  kkumku
//
//  Created by 임영택 on 1/6/25.
//

import UIKit

extension SearchDreamViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>
    
    enum Section: Int {
        case header
        case allTags
        case searchResults
    }
    
    enum Item: Hashable {
        case title(String)
        case tag(String)
        case dreamCard(Dream)
    }
    
    func initCollectionView() {
        registerCells()
        setDataSource()
        setLayout()
        applySnapshot()
    }
    
    private func registerCells() {
        headerCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            if case let .title(text) = item {
                var content = cell.defaultContentConfiguration()
                content.text = text
                content.textProperties.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                cell.contentConfiguration = content
            }
        }
        
        tagCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { cell, indexPath, item in
            if case let .tag(text) = item {
                var content = cell.defaultContentConfiguration()
                content.text = text
                content.textProperties.font = UIFont.systemFont(ofSize: 16)
                cell.contentConfiguration = content
            }
        }
    }
    
    private func setDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            if case .title(_) = item {
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.headerCellRegistration, for: indexPath, item: item)
                return cell
            }
            
            if case .tag(_) = item {
                let cell = collectionView.dequeueConfiguredReusableCell(using: self.tagCellRegistration, for: indexPath, item: item)
                return cell
            }
            
            if case let .dreamCard(dream) = item {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DreamCollectionViewCell", for: indexPath) as? DreamCollectionViewCell else {
                    Log.error("no cell")
                    return nil
                }
                
                cell.configure(dream: dream)
                return cell
            }
            
            return nil
        })
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.header, .allTags])
        
        snapshot.appendItems([.title("전체 태그")], toSection: .header)
        snapshot.appendItems(Array(1...10).map({ .tag("태그\($0)") }), toSection: .allTags)
        
        dataSource.apply(snapshot)
    }
    
    private func setLayout() {
        let sectionProvider: (Int, any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? = {sectionIndex, layoutEnvironment in
            let sectionKind = Section(rawValue: sectionIndex)
            
            if sectionKind == .header {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(48))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
                return section
            }
            
            if sectionKind == .allTags {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(36))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                return section
            }
            
            if sectionKind == .searchResults {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(300))
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 24
                return section
            }
            
            return nil
        }
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension SearchDreamViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Log.debug("did select at: \(indexPath)")
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let section = Section(rawValue: indexPath.section)
        
        if section == .header {
            return false
        }
        
        return true
    }
}
