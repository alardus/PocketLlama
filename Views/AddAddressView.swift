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
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $name)
                TextField("URL адрес", text: $url)
                Toggle("Использовать по умолчанию", isOn: $isDefault)
            }
            .navigationTitle("Добавить сервис")
            .navigationBarItems(
                leading: Button("Отмена") { dismiss() },
                trailing: Button("Сохранить") {
                    saveAddress()
                    dismiss()
                }
                .disabled(name.isEmpty || url.isEmpty)
            )
        }
    }
    
    private func saveAddress() {
        let newAddress = ServiceAddress(name: name, url: url, isDefault: isDefault)
        addresses.append(newAddress)
        AddressStorage.shared.saveAddresses(addresses)
    }
}

