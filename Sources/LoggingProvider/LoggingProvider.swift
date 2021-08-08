import os.log
public class LoggingProvider {
	public let subsystem:String
	
	private var loggers:[String:LogWrapper] = [:]
	
	public init(subsystem:String)
	{
		self.subsystem = subsystem
	}
	
	public func getLogger(forCategory category:String)->LogWrapper
	{
		return loggers[category] ?? createNewLogger(forCategory: category)
	}
	
	private func createNewLogger(forCategory category:String)->LogWrapper
	{
		
		if #available(iOS 14, *) {
			let visibility = LoggingConfigurator.shared.getVisibility(forSubsystem: subsystem, category: category)
			let logger = LoggerWrapper(subsystem: subsystem, category: category, visibility: visibility)
			loggers[category] = logger
			return logger
		} else {
			#if DEBUG
			let visibility = LoggingConfigurator.shared.getVisibility(forSubsystem: subsystem, category: category)
			let logger = PrintWrapper(subsystem: subsystem, category: category, visibility: visibility)
			#else
			print("empty logger created")
			let logger = EmptyWrapper(subsystem: subsystem, category: category)
			#endif
			loggers[category] = logger
			return logger
		}
	}
	
	public func log(level: OSLogType, _ message:String, forCategory category:String){
		getLogger(forCategory: category).log(level: level, message)
	}
	public func debug(_ message:String, forCategory category:String){
		getLogger(forCategory: category).debug(message)
	}
	public func trace(_ message:String, forCategory category:String){
		getLogger(forCategory: category).trace(message)
	}
	public func info(_ message:String, forCategory category:String){
		getLogger(forCategory: category).info(message)
	}
	public func notice(_ message:String, forCategory category:String){
		getLogger(forCategory: category).notice(message)
	}
	public func error(_ message:String, forCategory category:String){
		getLogger(forCategory: category).error(message)
	}
	public func warning(_ message:String, forCategory category:String){
		getLogger(forCategory: category).warning(message)
	}
	public func critical(_ message:String, forCategory category:String){
		getLogger(forCategory: category).critical(message)
	}
	public func fault(_ message:String, forCategory category:String){
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
	
	let visibility: LoggingVisibility
	
	init(subsystem:String, category:String, visibility: LoggingVisibility) {
		self.subsystem = subsystem
		self.category = category
		self.visibility = visibility
	}
	
	func log(level: OSLogType, _ message: String) {
		guard visibility <= LoggingVisibility(logType: level) else {return}
		print("\(subsystem):\(category) [\(level)] : \(message)")
	}
	
	func debug(_ message: String) {
		guard visibility <= .debug else {return}
		print("\(subsystem):\(category) [debug] : \(message)")
	}
	
	func trace(_ message: String) {
		guard visibility <= .trace else {return}
		print("\(subsystem):\(category) [trace] : \(message)")
	}
	
	func info(_ message: String) {
		guard visibility <= .info else {return}
		print("\(subsystem):\(category) [info] : \(message)")
	}
	
	func notice(_ message: String) {
		guard visibility <= .notice else {return}
		print("\(subsystem):\(category) [notice] : \(message)")
	}
	
	func error(_ message: String) {
		guard visibility <= .error else {return}
		print("\(subsystem):\(category) [error] : \(message)")
	}
	
	func warning(_ message: String) {
		guard visibility <= .warning else {return}
		print("\(subsystem):\(category) [warning] : \(message)")
	}
	
	func critical(_ message: String) {
		guard visibility <= .critical else {return}
		print("\(subsystem):\(category) [critical] : \(message)")
	}
	
	func fault(_ message: String) {
		guard visibility <= .fault else {return}
		print("\(subsystem):\(category) [fault] : \(message)")
	}
	
	
}

@available(iOS 14.0, *)
internal struct LoggerWrapper:LogWrapper
{
	var subsystem: String
	
	var category: String
	
	var logger:Logger
	
	let visibility: LoggingVisibility
	
	init(subsystem:String, category:String, visibility: LoggingVisibility) {
		self.subsystem = subsystem
		self.category = category
		logger = Logger(subsystem: subsystem, category: category)
		self.visibility = visibility
	}
	
	func log(level: OSLogType, _ message: String) {
		guard visibility <= LoggingVisibility(logType: level) else {return}
		logger.log(level: level, "\(message)")
	}
	
	func debug(_ message: String) {
		guard visibility <= .debug else {return}
		logger.debug("\(message)")
	}
	
	func trace(_ message: String) {
		guard visibility <= .trace else {return}
		logger.trace("\(message)")
	}
	
	func info(_ message: String) {
		guard visibility <= .info else {return}
		logger.info("\(message)")
	}
	
	func notice(_ message: String) {
		guard visibility <= .notice else {return}
		logger.notice("\(message)")
	}
	
	func error(_ message: String) {
		guard visibility <= .error else {return}
		logger.error("\(message)")
	}
	
	func warning(_ message: String) {
		guard visibility <= .warning else {return}
		logger.warning("\(message)")
	}
	
	func critical(_ message: String) {
		guard visibility <= .critical else {return}
		logger.critical("\(message)")
	}
	
	func fault(_ message: String) {
		guard visibility <= .fault else {return}
		logger.fault("\(message)")
	}
	
	
}

internal struct EmptyWrapper:LogWrapper
{
	var subsystem: String
	
	var category: String
	
	func log(level: OSLogType, _ message: String) {
		
	}
	
	func debug(_ message: String) {
		
	}
	
	func trace(_ message: String) {
		
	}
	
	func info(_ message: String) {
		
	}
	
	func notice(_ message: String) {
		
	}
	
	func error(_ message: String) {
		
	}
	
	func warning(_ message: String) {
		
	}
	
	func critical(_ message: String) {
		
	}
	
	func fault(_ message: String) {
		
	}
	
	
}
