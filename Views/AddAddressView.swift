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
            .navigationTitle("Добавить сервис")
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
        // Регулярное выражение для проверки формата URL с возможным портом
        let urlPattern = "^(http://|https://)?(\\d{1,3}\\.){3}\\d{1,3}(:\\d+)?$"
        let regex = try! NSRegularExpression(pattern: urlPattern)
        
        let range = NSRange(location: 0, length: url.utf16.count)
        if regex.firstMatch(in: url, options: [], range: range) != nil {
            let newAddress = ServiceAddress(name: name, url: url, isDefault: isDefault)
            addresses.append(newAddress)
            AddressStorage.shared.saveAddresses(addresses)
            dismiss() // Закрыть окно только при успешном сохранении
        } else {
            errorMessage = "Ошибка: адрес не соответствует формату URL." // Установить сообщение об ошибке
        }
    }
}

