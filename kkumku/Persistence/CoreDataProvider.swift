//
//  CoreDataProvider.swift
//  kkumku
//
//  Created by 임영택 on 1/29/25.
//

import CoreData

protocol CoreDataProvider {
    var persistentContainer: NSPersistentContainer { get }
}
