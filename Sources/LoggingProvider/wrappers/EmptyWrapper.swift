//
//  File.swift
//  
//
//  Created by la pieuvre on 13/05/2024.
//

import OSLog
internal struct EmptyWrapper: LogWrapper {
    
    
    var subsystem: String
    var category: String
    var visibility: LoggingVisibility = .none
    
    var debugCall: ((String) -> Void)? = nil
    var traceCall: ((String) -> Void)? = nil
    var infoCall: ((String) -> Void)? = nil
    var noticeCall: ((String) -> Void)? = nil
    var errorCall: ((String) -> Void)? = nil
    var warningCall: ((String) -> Void)? = nil
    var criticalCall: ((String) -> Void)? = nil
    var faultCall: ((String) -> Void)? = nil
    
    func debug(_: String) {}
    
    func trace(_: String) {}
    
    func info(_: String) {}
    
    func notice(_: String) {}
    
    func warning(_: String) {}
    
    func error(_: String) {}
    
    func critical(_: String) {}
    
    func fault(_: String) {}
}
