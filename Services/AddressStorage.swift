//
//  AddressStorage.swift
//  PocketLlama
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
    
//    func loadAddresses() -> [ServiceAddress] {
//        guard let data = userDefaults.data(forKey: addressesKey),
//              let addresses = try? JSONDecoder().decode([ServiceAddress].self, from: data) else {
//            // Return default addresses if no saved data exists
//            let defaultAddresses = [
//                ServiceAddress(name: "Stable Diffusion", url: "http://localhost:7860", isDefault: true),
//                ServiceAddress(name: "LLaMA.cpp", url: "http://localhost:8080", isDefault: false)
//            ]
//            // Save default addresses
//            saveAddresses(defaultAddresses)
//            return defaultAddresses
//        }
//        return addresses
//    }
    func loadAddresses() -> [ServiceAddress] {
        guard let data = userDefaults.data(forKey: addressesKey),
              let addresses = try? JSONDecoder().decode([ServiceAddress].self, from: data) else {
            return []
        }
        return addresses
    }
}
