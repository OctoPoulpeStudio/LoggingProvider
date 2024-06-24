import os.log
public class LoggingProvider {
    
    private static var providers: [String:LoggingProvider] = [:]
    public static func getProvider(forSubsystem subsystem: String) -> LoggingProvider {
        return providers[subsystem, orInsert: LoggingProvider(subsystem: subsystem)]
    }
    
    
    public let subsystem: String

    private var loggers: [String: LogWrapper] = [:]

    private init(subsystem: String) {
        self.subsystem = subsystem
    }

    public func getLogger(forCategory category: String) -> LogWrapper {
        return loggers[category] ?? createNewLogger(forCategory: category)
    }

    private func createNewLogger(forCategory category: String) -> LogWrapper {
        print("create logger for subsystem : \(subsystem) and cat: \(category)")
        let configuration = LoggingConfigurator.shared.getOrCreateConfiguration(forSubsystem: subsystem, category: category)
        let logger = LoggingConfigurator.shared.wrapperSelector.createNewLogger(forSubsystem: subsystem, category: category, configuration: configuration )
        loggers[category] = logger
        return logger
    }

    public func log(level: OSLogType, _ message: String, forCategory category: String) {
        getLogger(forCategory: category).log(level: level, message)
    }

    public func debug(_ message: String, forCategory category: String = "") {
        getLogger(forCategory: category).debug(message)
    }

    public func trace(_ message: String, forCategory category: String = "") {
        getLogger(forCategory: category).trace(message)
    }

    public func info(_ message: String, forCategory category: String = "") {
        getLogger(forCategory: category).info(message)
    }

    public func notice(_ message: String, forCategory category: String = "") {
        getLogger(forCategory: category).notice(message)
    }

    public func warning(_ message: String, forCategory category: String = "") {
        getLogger(forCategory: category).warning(message)
    }

    public func error(_ message: String, forCategory category: String = "") {
        getLogger(forCategory: category).error(message)
    }

    public func critical(_ message: String, forCategory category: String = "") {
        getLogger(forCategory: category).critical(message)
    }

    public func fault(_ message: String, forCategory category: String = "") {
        getLogger(forCategory: category).fault(message)
    }
}
