import SwiftUI

struct EditAddressView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var addresses: [ServiceAddress]
    let addressToEdit: ServiceAddress
    
    @State private var name: String
    @State private var url: String
    @State private var isDefault: Bool
    @State private var errorMessage: String?
    
    init(addresses: Binding<[ServiceAddress]>, addressToEdit: ServiceAddress) {
        self._addresses = addresses
        self.addressToEdit = addressToEdit
        _name = State(initialValue: addressToEdit.name)
        _url = State(initialValue: addressToEdit.url)
        _isDefault = State(initialValue: addressToEdit.isDefault)
    }
    
    var body: some View {
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
        .navigationTitle("Редактировать сервер")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Сохранить") {
                    saveAddress()
                }
                .disabled(name.isEmpty || url.isEmpty)
            }
        }
    }
    
    private func saveAddress() {
        // Регулярное выражение для проверки формата URL с возможным портом
        let urlPattern = "^(http://|https://)?(\\d{1,3}\\.){3}\\d{1,3}(:\\d+)?$"
        let regex = try! NSRegularExpression(pattern: urlPattern)
        
        let range = NSRange(location: 0, length: url.utf16.count)
        if regex.firstMatch(in: url, options: [], range: range) != nil {
            if let index = addresses.firstIndex(where: { $0.id == addressToEdit.id }) {
                addresses[index] = ServiceAddress(id: addressToEdit.id, name: name, url: url, isDefault: isDefault)
                AddressStorage.shared.saveAddresses(addresses)
                dismiss() // Закрыть окно только при успешном сохранении
            }
        } else {
            errorMessage = "Ошибка: адрес не соответствует формату URL." // Установить сообщение об ошибке
        }
    }
}
