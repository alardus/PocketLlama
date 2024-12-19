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
        let urlPattern = ".*"
        let regex = try! NSRegularExpression(pattern: urlPattern)
        
        let range = NSRange(location: 0, length: url.utf16.count)
        if regex.firstMatch(in: url, options: [], range: range) != nil {
            if isDefault {
                for i in 0..<addresses.count {
                    addresses[i].isDefault = false
                }
            }
            
            if let index = addresses.firstIndex(where: { $0.id == addressToEdit.id }) {
                let updatedAddress = ServiceAddress(id: addressToEdit.id, name: name, url: url, isDefault: isDefault)
                addresses[index] = updatedAddress
                AddressStorage.shared.saveAddresses(addresses)
                
                NotificationCenter.default.post(
                    name: Notification.Name("DefaultAddressChanged"),
                    object: isDefault ? updatedAddress : nil
                )
                
                dismiss()
            }
        } else {
            errorMessage = "Ошибка: адрес не соответствует формату URL."
        }
    }
}
