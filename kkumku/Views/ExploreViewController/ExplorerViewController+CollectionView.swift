//
//  ExplorerViewController+CollectionView.swift
//  kkumku
//
//  Created by 임영택 on 12/26/24.
//

import UIKit

extension ExploreViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Dream>
    enum Section {
        case main
    }
    
    func setDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, dream in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DreamCollectionViewCell", for: indexPath)
                    as? DreamCollectionViewCell else { return nil }
            
            cell.configure(dream: dream)
            
            return cell
        })
    }
    
    func setLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(300))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 24
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func applyDataSource(_ dreams: [Dream]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Dream>()
        snapshot.appendSections([.main])
        snapshot.appendItems(dreams, toSection: .main)
        dataSource.apply(snapshot)
    }
    
    func loadCurrentData() {
        let loaded = dreamRepository.fetchAll(sortBy: \DreamEntity.endAt, ascending: false, numberOfItems: numberOfItems, page: page)
        applyDataSource(loaded)
    }
    
    func appendMoreData() {
        guard !pageEnded else { return }
        
        page += 1
        let moreData = dreamRepository.fetchAll(sortBy: \DreamEntity.endAt, ascending: false, numberOfItems: numberOfItems, page: page)
        if moreData.count < numberOfItems {
            pageEnded.toggle()
            return
        }
        
        var snaphost = dataSource.snapshot()
        snaphost.appendItems(moreData, toSection: .main)
        dataSource.apply(snaphost)
    }
}

extension ExploreViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + 1) >= (scrollView.contentSize.height - scrollView.frame.size.height) {
            appendMoreData()
        }
    }
}
