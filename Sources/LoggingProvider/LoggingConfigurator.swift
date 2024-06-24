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

public class LoggingConfiguration {
    internal let category: String
    public var visibility: LoggingVisibility
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
            let configuration = LoggingConfigurator.shared.getConfiguration(forSubsystem: subsystem, category: category)
            return PrintWrapper(subsystem: subsystem, category: category, configuration: configuration)
        }, forProfile: .debug)
        
        wrapperSelector.add(loggerFactory: { subsystem, category, visibility in
            let configuration = LoggingConfigurator.shared.getConfiguration(forSubsystem: subsystem, category: category)
            if #available(iOS 14, *) {
                return LoggerWrapper(subsystem: subsystem, category: category, configuration: configuration)
                
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

        let categories = parse(domainName: domain)
        
        let currentConfig = getOrCreateSubcategoryConfiguration(tree: configsTree, subcategories: categories)
        assignVisibility(toSubtree: currentConfig, visibility: visibility)
    }
    
    private func getOrCreateSubcategoryConfiguration(tree: LoggingConfiguration, subcategories: [String])-> LoggingConfiguration {
        var defaultVisibility = tree.visibility
        var currentConfig = tree
        for subcategory in subcategories {
            currentConfig = currentConfig.subcategories[subcategory, orInsert: LoggingConfiguration(category: subcategory, visibility: defaultVisibility)]
            defaultVisibility = currentConfig.visibility
        }
        
        return currentConfig
    }
    
    private func assignVisibility(toSubtree subtree: LoggingConfiguration, visibility: LoggingVisibility) {
        subtree.visibility = visibility
        for subcategory in subtree.subcategories.keys {
            guard let subsubtree = subtree.subcategories[subcategory] else { continue }
            assignVisibility(toSubtree: subsubtree, visibility: visibility)
        }
    }
    
    public func getVisibility(forDomain domain: String) -> LoggingVisibility {
        let categories = parse(domainName: domain)
        return getOrCreateSubcategoryConfiguration(tree: configsTree, subcategories: categories).visibility
    }

    internal func getVisibility(forSubsystem subsystem: String, category: String) -> LoggingVisibility {
        /*
         Since we don'"t want to filter from the source the logs on none debug build, we can just return debug directly.
         Sparing resources for release build
         */
#if !DEBUG
        return .debug
#endif
        return getConfiguration(forSubsystem: subsystem, category: category).visibility
    }
    
    internal func getOrCreateConfiguration(forSubsystem subsystem: String, category: String) -> LoggingConfiguration {
        let categories = parse(domainName: subsystem + "." + category)
        return getOrCreateSubcategoryConfiguration(tree: configsTree, subcategories: categories)
    }
    
    internal func getConfiguration(forSubsystem subsystem: String, category: String) -> LoggingConfiguration {
        
        guard subsystem != "" else {
            return configsTree
        }
        
        let categories = parse(domainName: subsystem + "." + category)
        var currentConfig: LoggingConfiguration? = configsTree
        
        for category in categories.reversed() {
            currentConfig = currentConfig?.subcategories[category]
            if let currentConfig {
                return currentConfig
            }
        }
        return configsTree
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
