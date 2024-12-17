//
//  AddressStorage.swift
//  OpenWebUI
//
//  Created by Alexander Bykov on 14.12.24.
//

import Foundation

class AddressStorage {
    static let shared = AddressStorage()
    private let userDefaults = UserDefaults.standard
    private let addressesKey = "savedAddresses"
    
    func saveAddresses(_ addresses: [ServiceAddress]) {
        if let encoded = try? JSONEncoder().encode(addresses) {
            userDefaults.set(encoded, forKey: addressesKey)
        }
    }
    
    func loadAddresses() -> [ServiceAddress] {
        guard let data = userDefaults.data(forKey: addressesKey),
              let addresses = try? JSONDecoder().decode([ServiceAddress].self, from: data) else {
            return []
        }
        return addresses
    }
}

