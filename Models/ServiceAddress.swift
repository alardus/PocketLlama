//
//  ServiceAddress.swift
//  PocketLlama
//
//  Created by Alexander Bykov on 14.12.24.
//

import Foundation

struct ServiceAddress: Codable, Identifiable {
    let id: UUID
    var name: String
    var url: String
    var isDefault: Bool
    
    init(id: UUID = UUID(), name: String, url: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.url = url
        self.isDefault = isDefault
    }
}

