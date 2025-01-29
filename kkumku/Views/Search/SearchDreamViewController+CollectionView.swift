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
        applyInitailSnapshot()
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
        dataSource = DataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            guard let headerCellRegistration = self?.headerCellRegistration,
                  let tagCellRegistration = self?.tagCellRegistration else {
                      
                return UICollectionViewCell()
            }
            
            if case .title(_) = item {
                let cell = collectionView.dequeueConfiguredReusableCell(using: headerCellRegistration, for: indexPath, item: item)
                return cell
            }
            
            if case .tag(_) = item {
                let cell = collectionView.dequeueConfiguredReusableCell(using: tagCellRegistration, for: indexPath, item: item)
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
    
    func applyInitailSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.header, .allTags])
        currentSections = [.header, .allTags]
        
        snapshot.appendItems([.title("전체 태그")], toSection: .header)
        
        let tags: [String] = dreamRepository.fetchAllTags()
        loadedTags = tags
        let tagItems: [Item] = tags.map { tag in
            Item.tag(tag)
        }
        snapshot.appendItems(tagItems, toSection: .allTags)
        
        dataSource.apply(snapshot)
    }
    
    func applySnapshot(of searchResult: [Dream]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.header, .searchResults])
        currentSections = [.header, .searchResults]
        
        snapshot.appendItems([.title("검색 결과")], toSection: .header)
        
        let searchResultItems: [Item] = searchResult.map { dream in
            Item.dreamCard(dream)
        }
        snapshot.appendItems(searchResultItems, toSection: .searchResults)
        
        snapshot.reloadSections([.header, .searchResults])
        
        dataSource.apply(snapshot)
    }
    
    private func setLayout() {
        let sectionProvider: (Int, any NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? = { [weak self] sectionIndex, layoutEnvironment in
            guard let currentSections = self?.currentSections else {
                Log.error("currentSection이 nil이 되어서는 안됩니다")
                return nil
            }
            
            let sectionKind = currentSections[sectionIndex]
            
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
                section.interGroupSpacing = 8
                return section
            }
            
            Log.error("알 수 없는 섹션입니다 -- index \(sectionIndex)")
            return nil
        }
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension SearchDreamViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentSections = currentSections else {
            Log.error("currentSection이 nil이 되어서는 안됩니다")
            return
        }
        
        let section = currentSections[indexPath.section]
        
        if section == .allTags {
            let tag = loadedTags[indexPath.item]
            
            let searchController = navigationItem.searchController
            searchController?.searchBar.text = "#\(tag)"
            return
        }
        
        if section == .searchResults {
            let storyboard = DIContainerProvider.getStoryboardWithContainer(name: "DetailDreamView", bundle: nil)
            guard let detailViewController = storyboard.instantiateViewController(identifier: "DetailDreamViewController")
                    as? DetailDreamViewController else { return }
            detailViewController.dream = loadedDreams[indexPath.item]
            navigationController?.pushViewController(detailViewController, animated: true)
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let currentSections = currentSections else {
            Log.error("currentSection이 nil이 되어서는 안됩니다")
            return false
        }
        
        let section = currentSections[indexPath.section]
        
        if section == .header {
            return false
        }
        
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 스크롤되면 SearchBar에 대한 포커스를 없앤다
        navigationItem.searchController?.searchBar.resignFirstResponder()
    }
}
