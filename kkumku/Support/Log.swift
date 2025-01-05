//
//  Logger.swift
//  kkumku
//
//  Created by 임영택 on 1/5/25.
//

import Foundation
import os

class Log {
    private static var loggers: [LogCategory: Logger] = {
        var workingDict: [LogCategory: Logger] = [:]
        
        LogCategory.allCases.forEach { category in
            workingDict[category] = Logger(subsystem: "com.youngtaek.kkumku", category: category.rawValue)
        }
        
        return workingDict
    }()
    
    private static let usePrintNotOSLog: Bool = {
        guard let filePath = Bundle.main.path(forResource: "Configs", ofType: "plist"),
              let configDict = NSDictionary(contentsOfFile: filePath) else {
            fatalError("Configs.plist를 불러오지 못했습니다")
        }
        
        guard let logConfigDict = configDict.object(forKey: "Log") as? NSDictionary,
              let shouldUsePrint = logConfigDict.object(forKey: "LogWithPrint") as? Bool else {
            fatalError("Configs.plist / Log / LogWithPrint 설정을 불러오지 못했습니다.")
        }
        
       return shouldUsePrint
    }()
    
    private static func writeWithOSLog(_ message: String, level: LogLevel, category: LogCategory) {
        if let logger = loggers[category] {
            switch level {
            case .info:
                logger.info("\(message)")
            case .debug:
                logger.debug("\(message)")
            case .error:
                logger.error("\(message)")
            }
        }
    }
    
    static func info(_ message: String, for category: LogCategory = LogCategory.domain) {
        if !usePrintNotOSLog {
            writeWithOSLog(message, level: .info, category: category)
        } else {
            print("\(Date.now.timeStampForLog) [INFO] \(message)")
        }
    }
    
    static func debug(_ message: String, for category: LogCategory = LogCategory.domain) {
        if !usePrintNotOSLog {
            writeWithOSLog(message, level: .debug, category: category)
        } else {
            print("\(Date.now.timeStampForLog) [DEBUG] \(message)")
        }
    }
    
    static func error(_ message: String, for category: LogCategory = LogCategory.domain) {
        if !usePrintNotOSLog {
            writeWithOSLog(message, level: .error, category: category)
        } else {
            print("\(Date.now.timeStampForLog) [ERROR] \(message)")
        }
    }
    
    private enum LogLevel {
        case info
        case debug
        case error
    }
    
    enum LogCategory: String, CaseIterable {
        case domain
        case network
        case system
    }
}

