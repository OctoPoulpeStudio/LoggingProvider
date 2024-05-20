//
//  File.swift
//  
//
//  Created by la pieuvre on 13/05/2024.
//

import OSLog

@available(iOS 14.0, *)
internal class LoggerWrapper: LogWrapper {
    var debugCall: ((String) -> Void)?
    
    var traceCall: ((String) -> Void)?
    
    var infoCall: ((String) -> Void)?
    
    var noticeCall: ((String) -> Void)?
    
    var errorCall: ((String) -> Void)?
    
    var warningCall: ((String) -> Void)?
    
    var criticalCall: ((String) -> Void)?
    
    var faultCall: ((String) -> Void)?
    
    var subsystem: String
    
    var category: String
    
    var logger: Logger
    
    let visibility: LoggingVisibility
    
    init(subsystem: String, category: String, visibility: LoggingVisibility) {
        self.subsystem = subsystem
        self.category = category
        logger = Logger(subsystem: subsystem, category: category)
        self.visibility = visibility
        
        
        debugCall = { message in
            self.logger.debug("\(message)")
        }
        
        traceCall = { message in
            self.logger.trace("\(message)")
        }
        
        infoCall = { message in
            self.logger.info("\(message)")
        }
        
        noticeCall = { message in
            self.logger.notice("\(message)")
        }
        
        warningCall = { message in
            self.logger.warning("\(message)")
        }
        
        errorCall = { message in
            self.logger.error("\(message)")
        }
        
        criticalCall = { message in
            self.logger.critical("\(message)")
        }
        
        faultCall = { message in
            self.logger.fault("\(message)")
        }
    }
    
    func log(level: OSLogType, _ message: String) {
        guard visibility <= LoggingVisibility(logType: level) else { return }
        logger.log(level: level, "\(message)")
    }
    
    
}
