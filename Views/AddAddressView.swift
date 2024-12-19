//
//  AddAddressView.swift
//  OpenWebUI
//
//  Created by Alexander Bykov on 14.12.24.
//

import SwiftUI

struct AddAddressView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var addresses: [ServiceAddress]
    
    @State private var name = ""
    @State private var url = ""
    @State private var isDefault = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $name)
                TextField("URL адрес", text: $url)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                Toggle("Использовать по умолчанию", isOn: $isDefault)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Добавить сервер")
            .navigationBarItems(
                leading: Button("Отмена") { dismiss() },
                trailing: Button("Сохранить") {
                    saveAddress()
                }
                .disabled(name.isEmpty || url.isEmpty)
            )
        }
    }
    
    private func saveAddress() {
        let urlPattern = ".*"
        let regex = try! NSRegularExpression(pattern: urlPattern)
        
        let range = NSRange(location: 0, length: url.utf16.count)
        if regex.firstMatch(in: url, options: [], range: range) != nil {
            if isDefault {
                for i in 0..<addresses.count {
                    addresses[i].isDefault = false
                }
            }
            
            let newAddress = ServiceAddress(name: name, url: url, isDefault: isDefault)
            addresses.append(newAddress)
            AddressStorage.shared.saveAddresses(addresses)
            
            NotificationCenter.default.post(
                name: Notification.Name("DefaultAddressChanged"),
                object: isDefault ? newAddress : nil
            )
            
            dismiss()
        } else {
            errorMessage = "Ошибка: адрес не соответствует формату URL."
        }
    }
}

