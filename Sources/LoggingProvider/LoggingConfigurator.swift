//
//  File.swift
//
//
//  Created by la pieuvre on 05/08/2021.
//
import Foundation
import os

public enum LoggingVisibility: Int, Comparable {
    public static func < (lhs: LoggingVisibility, rhs: LoggingVisibility) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// the lowest level logging : rawValue = 0
    case debug = 0
    /// rawValue = 1
    case trace
    /// rawValue = 2
    case info
    /// rawValue = 3
    case notice
    /// rawValue = 4
    case warning
    /// rawValue = 5
    case error
    /// rawValue = 6
    case critical
    /// rawValue = 7
    case fault
    /// rawValue = 8
    case none

    public init(logType: OSLogType) {
        switch logType {
        case .debug:
            self = .debug
        case .default:
            self = .debug
        case .error:
            self = .error
        case .fault:
            self = .fault
        case .info:
            self = .info
        default:
            self = .debug
        }
    }
}

internal class LoggingConfiguration {
    internal let category: String
    internal var visibility: LoggingVisibility
    internal var subcategories: [String: LoggingConfiguration] = [:]

    internal init(category: String, visibility: LoggingVisibility) {
        self.category = category
        self.visibility = visibility
    }
}

public class LoggingConfigurator {
    public static let shared: LoggingConfigurator = .init()
    
    public let wrapperSelector: WrapperSelector = .init()

    private init() {
        wrapperSelector.add(loggerFactory: { subsystem, category, visibility in
            let visibility = LoggingConfigurator.shared.getVisibility(forSubsystem: subsystem, category: category)
            return PrintWrapper(subsystem: subsystem, category: category, visibility: visibility)
        }, forProfile: .debug)
        
        wrapperSelector.add(loggerFactory: { subsystem, category, visibility in
            let visibility = LoggingConfigurator.shared.getVisibility(forSubsystem: subsystem, category: category)
            if #available(iOS 14, *) {
                return LoggerWrapper(subsystem: subsystem, category: category, visibility: visibility)
                
            } else {
                print("empty logger created")
                return EmptyWrapper(subsystem: subsystem, category: category)
            }
        }, forProfile: .release)
    }

    private var configsTree: LoggingConfiguration = .init(category: "", visibility: .debug)

    public func add(visibility: LoggingVisibility, forDomain domain: String) {
        /*
         Log are stored in a file when logger is used on released version.
         we want those logs to be added to the file so we can filter them later from the console app
         Therefore there is no need for configuration on none debug version.
         */
        #if !DEBUG
            return
        #endif

        guard domain != "" else {
            configsTree.visibility = visibility
            return
        }

        let categories = parse(domainName: domain)

        var currentConfig: LoggingConfiguration = configsTree
        var parentVisibility: LoggingVisibility = configsTree.visibility
        for (i, subcategory) in categories.enumerated() {
            let isBranch = i < categories.count - 1
            parentVisibility = max(.debug, parentVisibility)
            // create the visibility for the leaf or for a newly created parent
            let currentVisibility: LoggingVisibility = isBranch ? .debug : visibility
            if let subConfig = currentConfig.subcategories[subcategory] {
                if !isBranch {
                    subConfig.visibility = currentVisibility
                }
                currentConfig = subConfig
            } else {
                let newConfig = LoggingConfiguration(category: subcategory, visibility: currentVisibility)
                currentConfig.subcategories[subcategory] = newConfig
                currentConfig = newConfig
            }
        }
    }

    internal func getVisibility(forSubsystem subsystem: String, category: String) -> LoggingVisibility {
        /*
         Since we don'"t want to filter from the source the logs on none debug build, we can just return debug directly.
         Sparing resources for release build
         */
        #if !DEBUG
            return .debug
        #endif
        guard subsystem != "" else {
            return configsTree.visibility
        }

        let categories = parse(domainName: subsystem + "." + category)
        var currentConfig: LoggingConfiguration? = configsTree
        var parentVisibility = configsTree.visibility
        for category in categories {
            currentConfig = currentConfig?.subcategories[category]
            if currentConfig == nil {
                return parentVisibility
            }
            parentVisibility = max(parentVisibility, currentConfig?.visibility ?? .debug)
        }
        return parentVisibility
    }
}

internal func parse(domainName: String) -> [String] {
    let categories = Array(domainName.split(separator: "."))
    var r: [String] = []

    for subString in categories {
        r.append(String(subString))
    }

    return r
}
