import os.log
struct LoggingProvider {
	public let subsystem:String
	
	private var loggers:[String:LogWrapper] = [:]
	
	public init(subsystem:String)
	{
		self.subsystem = subsystem
	}
	
	public mutating func getLogger(forCategory category:String)->LogWrapper
	{
		return loggers[category] ?? createNewLogger(forCategory: category)
	}
	
	private mutating func createNewLogger(forCategory category:String)->LogWrapper
	{
		if #available(iOS 14, *) {
			let logger = LoggerWrapper(subsystem: subsystem, category: category)
			loggers[category] = logger
			return logger
		} else {
			let logger = PrintWrapper(subsystem: subsystem, category: category)
			loggers[category] = logger
			return logger
		}
	}
	
	public mutating func log(level: OSLogType, _ message:String, forCategory category:String){
		getLogger(forCategory: category).log(level: level, message)
	}
	public mutating func debug(_ message:String, forCategory category:String){
		getLogger(forCategory: category).debug(message)
	}
	public mutating func trace(_ message:String, forCategory category:String){
		getLogger(forCategory: category).trace(message)
	}
	public mutating func info(_ message:String, forCategory category:String){
		getLogger(forCategory: category).info(message)
	}
	public mutating func notice(_ message:String, forCategory category:String){
		getLogger(forCategory: category).notice(message)
	}
	public mutating func error(_ message:String, forCategory category:String){
		getLogger(forCategory: category).error(message)
	}
	public mutating func warning(_ message:String, forCategory category:String){
		getLogger(forCategory: category).warning(message)
	}
	public mutating func critical(_ message:String, forCategory category:String){
		getLogger(forCategory: category).critical(message)
	}
	public mutating func fault(_ message:String, forCategory category:String){
		getLogger(forCategory: category).fault(message)
	}
}


public protocol LogWrapper
{
	var subsystem:String {get}
	var category:String{get}
	
	func log(level:OSLogType, _ message:String)
	func debug(_ message:String)
	func trace(_ message:String)
	func info(_ message:String)
	func notice(_ message:String)
	func error(_ message:String)
	func warning(_ message:String)
	func critical(_ message:String)
	func fault(_ message:String)
}

internal struct PrintWrapper:LogWrapper
{
	var subsystem: String
	
	var category: String
	
	func log(level: OSLogType, _ message: String) {
		print("\(subsystem):\(category) [\(level)] : \(message)")
	}
	
	func debug(_ message: String) {
		print("\(subsystem):\(category) [debug] : \(message)")
	}
	
	func trace(_ message: String) {
		print("\(subsystem):\(category) [trace] : \(message)")
	}
	
	func info(_ message: String) {
		print("\(subsystem):\(category) [info] : \(message)")
	}
	
	func notice(_ message: String) {
		print("\(subsystem):\(category) [notice] : \(message)")
	}
	
	func error(_ message: String) {
		print("\(subsystem):\(category) [error] : \(message)")
	}
	
	func warning(_ message: String) {
		print("\(subsystem):\(category) [warning] : \(message)")
	}
	
	func critical(_ message: String) {
		print("\(subsystem):\(category) [critical] : \(message)")
	}
	
	func fault(_ message: String) {
		print("\(subsystem):\(category) [fault] : \(message)")
	}
	
	
}

@available(iOS 14.0, *)
internal struct LoggerWrapper:LogWrapper
{
	var subsystem: String
	
	var category: String
	
	var logger:Logger
	
	init(subsystem:String, category:String) {
		self.subsystem = subsystem
		self.category = category
		logger = Logger(subsystem: subsystem, category: category)
	}
	
	func log(level: OSLogType, _ message: String) {
		logger.log(level: level, OSLogMessage(stringLiteral: message))
	}
	
	func debug(_ message: String) {
		logger.debug(OSLogMessage(stringLiteral: message))
	}
	
	func trace(_ message: String) {
		logger.trace(OSLogMessage(stringLiteral: message))
	}
	
	func info(_ message: String) {
		logger.info(OSLogMessage(stringLiteral: message))
	}
	
	func notice(_ message: String) {
		logger.notice(OSLogMessage(stringLiteral: message))
	}
	
	func error(_ message: String) {
		logger.error(OSLogMessage(stringLiteral: message))
	}
	
	func warning(_ message: String) {
		logger.warning(OSLogMessage(stringLiteral: message))
	}
	
	func critical(_ message: String) {
		logger.critical(OSLogMessage(stringLiteral: message))
	}
	
	func fault(_ message: String) {
		logger.fault(OSLogMessage(stringLiteral: message))
	}
	
	
}
