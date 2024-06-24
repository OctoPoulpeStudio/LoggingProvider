//
//  File.swift
//  
//
//  Created by la pieuvre on 13/05/2024.
//

import OSLog
internal struct PrintWrapper: LogWrapper {
    var subsystem: String
    
    var category: String
    
    var configuration: LoggingConfiguration
    
    var debugCall: ((String) -> Void)?
    var traceCall: ((String) -> Void)?
    var infoCall: ((String) -> Void)?
    var noticeCall: ((String) -> Void)?
    var errorCall: ((String) -> Void)?
    var warningCall: ((String) -> Void)?
    var criticalCall: ((String) -> Void)?
    var faultCall: ((String) -> Void)?
    
    init(subsystem: String, category: String, configuration: LoggingConfiguration) {
        self.subsystem = subsystem
        self.category = category
        self.configuration = configuration
        
        debugCall = {message in
            print("\(subsystem):\(category) [debug] : \(message)")
        }
        
        traceCall = {message in
            print("\(subsystem):\(category) [trace] : \(message)")
        }
        
        infoCall = {message in
            print("\(subsystem):\(category) [info] : \(message)")
        }
        
        noticeCall = {message in
            print("\(subsystem):\(category) [notice] : \(message)")
        }
        
        warningCall = {message in
            print("\(subsystem):\(category) [warning] : \(message)")
        }
        
        errorCall = {message in
            print("\(subsystem):\(category) [error] : \(message)")
        }
        
        criticalCall = {message in
            print("\(subsystem):\(category) [critical] : \(message)")
        }
        
        faultCall = {message in
            print("\(subsystem):\(category) [fault] : \(message)")
        }
    }
    
    func log(level: OSLogType, _ message: String) {
        guard configuration.visibility <= LoggingVisibility(logType: level) else { return }
        print("\(subsystem):\(category) [\(level)] : \(message)")
    }
}

