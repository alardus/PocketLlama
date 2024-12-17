import SwiftUI
import WebKit

struct ContentView: View {
    @State private var addresses: [ServiceAddress] = []
    @State private var showingAddSheet = false
    @State private var selectedAddress: ServiceAddress?
    @State private var showingSideMenu = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let address = selectedAddress {
                    WebViewContainer(url: address.url)
                        .ignoresSafeArea(edges: .bottom) // Игнорируем только нижнюю safe area
                } else {
                    Text("Выберите адрес сервиса")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Open WebUI")
            .navigationBarTitleDisplayMode(.inline) // Делаем заголовок компактным
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSideMenu = true
                    }) {
                        Image(systemName: "list.bullet")
                    }
                }
            }
        }
        .sheet(isPresented: $showingSideMenu) {
            List(addresses) { address in
                Button(action: {
                    selectedAddress = address
                    showingSideMenu = false
                }) {
                    VStack(alignment: .leading) {
                        Text(address.name)
                            .font(.headline)
                        Text(address.url)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .presentationDetents([.medium, .large])
        }
        .onAppear(perform: loadSavedAddresses)
        .sheet(isPresented: $showingAddSheet) {
            AddAddressView(addresses: $addresses)
        }
    }
    
    private func loadSavedAddresses() {
        addresses = AddressStorage.shared.loadAddresses()
        if let defaultAddress = addresses.first(where: { $0.isDefault }) {
            selectedAddress = defaultAddress
        }
    }
}