//
//  File.swift
//  
//
//  Created by la pieuvre on 14/05/2024.
//

import Foundation
internal extension Dictionary {
    subscript(key: Key, orInsert defaultValue: @autoclosure () -> Value) -> Value {
        mutating get {
            if let value = self[key] {
                return value
            } else {
                let value = defaultValue()
                self[key] = value
                return value
            }
        }
    }
}
