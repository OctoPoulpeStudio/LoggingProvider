//
//  File.swift
//  
//
//  Created by la pieuvre on 13/05/2024.
//

import OSLog

internal class CombinedLoggerWrapper: LogWrapper {
    
    
    
    private var wrappers: [LogWrapper] = []
    
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
    
    internal init(subsystem: String, category: String, configuration: LoggingConfiguration) {
        self.subsystem = subsystem
        self.category = category
        self.configuration = configuration
        
        debugCall = { message in
            for wrapper in self.wrappers {
                wrapper.debug(message)
            }
        }
        
        traceCall = { message in
            for wrapper in self.wrappers {
                wrapper.trace(message)
            }
        }
        
        infoCall = { message in
            for wrapper in self.wrappers {
                wrapper.info(message)
            }
        }
        
        noticeCall = { message in
            for wrapper in self.wrappers {
                wrapper.notice(message)
            }
        }
        
        errorCall = { message in
            for wrapper in self.wrappers {
                wrapper.error(message)
            }
        }
        
        warningCall = { message in
            for wrapper in self.wrappers {
                wrapper.warning(message)
            }
        }
        
        criticalCall = { message in
            for wrapper in self.wrappers {
                wrapper.critical(message)
            }
        }
        
        faultCall = { message in
            for wrapper in self.wrappers {
                wrapper.fault(message)
            }
        }
    }
    
    func add(logger: LogWrapper) {
        var logger = logger
        logger.configuration = configuration
        wrappers.append(logger)
    }
    
    func log(level: OSLogType, _ message: String) {
        for wrapper in wrappers {
            wrapper.log(level: level, message)
        }
    }
    
    
    
    
}
