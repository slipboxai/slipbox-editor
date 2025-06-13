//
//  Item.swift
//  SlipboxEditorDemo
//
//  Created by Brandon Weng on 2025-06-12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
