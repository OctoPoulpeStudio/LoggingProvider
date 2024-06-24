//
//  File.swift
//  
//
//  Created by la pieuvre on 13/05/2024.
//

import OSLog

public struct VisibilityUtil {
    static func shouldLog(currentVisibility: LoggingVisibility, messageVisibility: LoggingVisibility) -> Bool {
        return messageVisibility.rawValue >= currentVisibility.rawValue
    }
}

public protocol LogWrapper {
    var subsystem: String { get }
    var category: String { get }
    var configuration: LoggingConfiguration { get set}
    
    var debugCall:((String)->Void)? {get set}
    var traceCall:((String) -> Void)? {get set}
    var infoCall:((String) -> Void)? {get set}
    var noticeCall:((String) -> Void)? {get set}
    var errorCall:((String) -> Void)? {get set}
    var warningCall:((String) -> Void)? {get set}
    var criticalCall:((String) -> Void)? {get set}
    var faultCall:((String) -> Void)? {get set}
    
    func log(level: OSLogType, _ message: String)
    func debug(_ message: String)
    func trace(_ message: String)
    func info(_ message: String)
    func notice(_ message: String)
    func error(_ message: String)
    func warning(_ message: String)
    func critical(_ message: String)
    func fault(_ message: String)
}

public extension LogWrapper {
    func log(level: OSLogType, _ message: String) {
        switch level{
            case .debug :
                debug(message)
            case .info :
                info(message)
            case .error :
                error(message)
            case .fault :
                fault(message)
            case .default :
                debug(message)
            default:
                debug(message)
        }
    }
    
    func debug(_ message: String) {
        logIfVisible(message: message, visibility: .debug, logMethod: debugCall)
    }
    
    func trace(_ message: String) {
        logIfVisible(message: message, visibility: .trace, logMethod: traceCall)
    }
    
    func info(_ message: String) {
        logIfVisible(message: message, visibility: .info, logMethod: infoCall)
    }
    
    func notice(_ message: String) {
        logIfVisible(message: message, visibility: .notice, logMethod: noticeCall)
    }
    
    func warning(_ message: String) {
        logIfVisible(message: message, visibility: .warning, logMethod: warningCall)
    }
    
    func error(_ message: String) {
        logIfVisible(message: message, visibility: .error, logMethod: errorCall)
    }
    
    func critical(_ message: String) {
        logIfVisible(message: message, visibility: .critical, logMethod: criticalCall)
    }
    
    func fault(_ message: String) {
        logIfVisible(message: message, visibility: .fault, logMethod: faultCall)
    }
    
    private func logIfVisible(message: String, visibility: LoggingVisibility, logMethod: ((String) -> Void)?) {
        guard VisibilityUtil.shouldLog(currentVisibility: self.configuration.visibility, messageVisibility: visibility) else { return }
        logMethod?(message)
    }
}
