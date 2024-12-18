import SwiftUI
import WebKit

struct ContentView: View {
    @State private var addresses: [ServiceAddress] = []
    @State private var showingAddSheet = false
    @State private var selectedAddress: ServiceAddress?
    @State private var showingSideMenu = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let address = selectedAddress {
                    WebViewContainer(url: address.url)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    Text("Выберите адрес сервиса")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Open WebUI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showingAbout = true }) {
                        Image(systemName: "info.circle")
                    }
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
            NavigationStack {
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
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            if let index = addresses.firstIndex(where: { $0.id == address.id }) {
                                addresses.remove(at: index)
                                AddressStorage.shared.saveAddresses(addresses)
                                if selectedAddress?.id == address.id {
                                    selectedAddress = addresses.first
                                }
                            }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                        
                        NavigationLink {
                            EditAddressView(addresses: $addresses, addressToEdit: address)
                        } label: {
                            Label("Изменить", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Список серверов")
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
                .presentationDetents([.medium])
        }
        .onAppear(perform: loadSavedAddresses)
        .sheet(isPresented: $showingAddSheet) {
            AddAddressView(addresses: $addresses)
        }
    }
    
    private func loadSavedAddresses() {
        print("Loading saved addresses...")
        let loadedAddresses = AddressStorage.shared.loadAddresses()
        print("Loaded \(loadedAddresses.count) addresses")
        
        DispatchQueue.main.async {
            self.addresses = loadedAddresses
            if self.selectedAddress == nil {
                self.selectedAddress = loadedAddresses.first(where: { $0.isDefault }) ?? loadedAddresses.first
            }
        }
    }
}

// Отдельное view для окна About
struct AboutView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "network")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Open WebUI")
                    .font(.title)
                    .bold()
                
                Text("Версия 0.0.1")
                    .foregroundColor(.secondary)
                
                Text("OpenUI — современное приложение для удобной работы с серверами Ollama на мобильных устройствах")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Link("Проект на GitHub", destination: URL(string: "https://github.com/alardus/openui-swift")!)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("О приложении")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
