//
//  File.swift
//  
//
//  Created by la pieuvre on 13/05/2024.
//

import OSLog

/// Allow the user to add custom wrapper to log to specific target for exemple
public class WrapperSelector {
    
    
    private var loggerProfiles: [LoggingProfile: [(String, String, LoggingVisibility)->LogWrapper]] = [:]
    
    public func add(loggerFactory:@escaping (String, String, LoggingVisibility)->LogWrapper, forProfile profile: LoggingProfile) {
        loggerProfiles[profile, default: []].append(loggerFactory)
    }
    
    internal func createNewLogger(forSubsystem subsystem: String,  category: String, visibility: LoggingVisibility) -> LogWrapper {
        let result = CombinedLoggerWrapper(subsystem: subsystem, category: category, visibility: visibility)
#if DEBUG
        let currentProfile = LoggingProfile.debug
#else
        let currentProfile = LoggingProfile.release
#endif
        guard let profiles = loggerProfiles[currentProfile] else {return EmptyWrapper(subsystem: subsystem, category: category, visibility: visibility)}
        for factory in profiles {
            result.add(logger:factory(subsystem, category, visibility))
        }
        return result
    }
}
