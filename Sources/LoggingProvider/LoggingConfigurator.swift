//
//  File.swift
//  
//
//  Created by la pieuvre on 05/08/2021.
//

import os

public enum LoggingVisibility: Int, Comparable
{
	public static func < (lhs: LoggingVisibility, rhs: LoggingVisibility) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
	
	case debug = 0
	case trace
	case info
	case notice
	case warning
	case error
	case critical
	case fault
	case none
	
	public init(logType:OSLogType)
	{
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

internal class LoggingConfiguration
{
	internal let category:String
	internal var visibility: LoggingVisibility
	internal var subcategories:[String:LoggingConfiguration] = [:]
	
	internal init(category:String, visibility: LoggingVisibility)
	{
		self.category = category
		self.visibility = visibility
	}
}

public class LoggingConfigurator
{
	
	public static let shared:LoggingConfigurator = LoggingConfigurator()
	
	private init(){}
	
	private var configsTree:LoggingConfiguration = LoggingConfiguration(category: "", visibility: .debug)
	
	public func add(visibility: LoggingVisibility, forDomain domain:String)
	{
		/*
		Log are stored in a file when logger is used on released version.
		we want those logs to be added to the file so we can filter them later from the console app
		Therefore there is no need for configuration on none debug version.
		*/
		#if !DEBUG
		return
		#endif
		
		let categories = parse(domainName: domain)
		
		var currentConfig:LoggingConfiguration = configsTree
		for i in 0..<categories.count {
			let subcategory = categories[i]
			let isLeaf = i < categories.count - 1
			let currentVisibility: LoggingVisibility =  isLeaf ? .debug : visibility
			if  let  subConfig = currentConfig.subcategories[subcategory]
			{
				if isLeaf
				{
					subConfig.visibility = currentVisibility
				}
				currentConfig = subConfig
			}
			else
			{
				let newConfig = LoggingConfiguration(category: subcategory, visibility: currentVisibility)
				currentConfig.subcategories[subcategory] = newConfig
				currentConfig = newConfig
			}
		}
	}
	
	internal func getVisibility(forSubsystem subsystem:String, category:String)->LoggingVisibility
	{
		/*
		Since we don'"t want to filter from the source the logs on none debug build, we can just return debug directly.
		Sparing resources for release build
		*/
		#if !DEBUG
		return .debug
		#endif
		let categories = parse(domainName: subsystem+"."+category)
		var currentConfig:LoggingConfiguration? = configsTree
		for category in categories {
			currentConfig = currentConfig?.subcategories[category]
			if currentConfig == nil {
				return .debug
			}
		}
		return currentConfig?.visibility ?? .debug
	}
}

internal func parse(domainName:String)->[String]
{
	let categories = Array(domainName.split(separator: "."))
	var r : [String] = []
	
	for subString in categories {
		r.append(String(subString))
	}
	
	return r
}
