//
//  Utils.swift
//  kkumku
//
//  Created by 임영택 on 1/19/25.
//

import Foundation

class Utils {
    // ref: https://stackoverflow.com/a/40634366
    @MainActor
    class Debouncer {
        private var task: Task<Void, Never>?
        private let seconds: TimeInterval
        
        init(seconds: TimeInterval) {
            self.seconds = seconds
        }

        func debounce(action: @escaping (() -> Void)) {
            task?.cancel()
            task = Task {
                do {
                    try await Task.sleep(for: .seconds(seconds))
                    action()
                } catch let error as NSError {
                    if let _ = error as? CancellationError {
                        Log.debug("task canceled...")
                    } else {
                        Log.error("other error on debouncing... \(error.domain) \(error.localizedDescription) \(error.userInfo)")
                    }
                }
            }
        }
    }
}
