//
//  DreamRepositoryProtocol.swift
//  kkumku
//
//  Created by 임영택 on 1/29/25.
//

import CoreData

protocol DreamRepositoryProtocol {
    func withContext<T>(_ task: (_ context: NSManagedObjectContext) throws -> T,
                     onFailure: ((_ context: NSManagedObjectContext, _ error: Error) -> Void)? ) -> T?
    
    func save(_ dream: Dream) -> Dream?
    
    func update(context: NSManagedObjectContext, dream: Dream, found originalEntity: DreamEntity) throws -> DreamEntity
    
    func insert(context: NSManagedObjectContext, dream: Dream) throws -> DreamEntity
    
    func fetchAll(sortBy: AnyKeyPath, ascending: Bool, numberOfItems: Int, page: Int) -> [Dream]
    
    func find(id: UUID) -> Dream?
    
    func findAll(containing query: String) -> [Dream]
    
    func findAll(from startDate: Date, to endDate: Date) -> [Dream]
    
    func delete(by id: UUID)
    
    func fetchAllTags() -> [String]
}
