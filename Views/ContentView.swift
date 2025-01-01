import SwiftUI
import WebKit

struct Server {
    let name: String
    let url: String
}

class ContentViewModel: ObservableObject {
    @Published var selectedServer: Server?
    
    func updateSelectedServer(_ address: ServiceAddress?) {
        if let address = address {
            selectedServer = Server(name: address.name, url: address.url)
        } else {
            selectedServer = nil
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var addresses: [ServiceAddress] = []
    @State private var showingAddSheet = false
    @State private var selectedAddress: ServiceAddress?
    @State private var showingSideMenu = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Spacer()
                if let address = selectedAddress {
                    WebViewContainer(url: address.url)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    
                    Image("AppIconAbout")
                        .resizable()
                        .frame(width: 128, height: 128)
                        .offset(y: -100)
                    
                    Text("Выберите или добавьте сервер")
                        .foregroundColor(.gray);
                    Button(action: { showingAddSheet = true }) {
                        Text("Добавить адрес сервера")
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding() // Общие отступы
                    .offset(y: 50) // Смещение вниз на 50 точек
                }
            }
            .navigationTitle(viewModel.selectedServer?.name ?? "PocketLlama")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(viewModel.selectedServer?.name ?? "PocketLlama")
                            .font(.headline)
                        if let server = viewModel.selectedServer {
                            Text(server.url)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
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
                        Image(systemName: "server.rack")
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
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("DefaultAddressChanged"))) { notification in
            if let newDefaultAddress = notification.object as? ServiceAddress {
                self.selectedAddress = newDefaultAddress
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddAddressView(addresses: $addresses)
        }
        .onChange(of: selectedAddress) { newAddress in
            viewModel.updateSelectedServer(newAddress)
        }
    }
    
    private func loadSavedAddresses() {
        print("Loading saved addresses...")
        let loadedAddresses = AddressStorage.shared.loadAddresses()
        print("Loaded \(loadedAddresses.count) addresses")
        
        DispatchQueue.main.async {
            self.addresses = loadedAddresses
            let defaultAddress = loadedAddresses.first(where: { $0.isDefault })
            self.selectedAddress = defaultAddress
            viewModel.updateSelectedServer(defaultAddress)
        }
    }
}

// Отдельное view для окна About
struct AboutView: View {
    var body: some View {
        NavigationStack {
            VStack() {
                Image("AppIconAbout")
                    .resizable()
                    .frame(width: 60, height: 60)
                
                Text("PocketLlama")
                    .font(.title)
                    .bold()
                
                Text("Версия \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
        
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("О приложении")
            .navigationBarTitleDisplayMode(.inline)
            
            VStack(spacing: 20) {
                Text("Приложение для удобной работы с серверами Ollama на мобильных устройствах")
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                Spacer()
                

                Link("Проект на GitHub", destination: URL(string: "https://github.com/alardus/PocketLlama")!)
                    .foregroundColor(.blue)
                
                Spacer()


                Text("Alexander Bykov \n Made with ❤ 2024-2025")
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                
                Spacer()
                
            }
        }
    }
}

extension ServiceAddress: Equatable {
    static func == (lhs: ServiceAddress, rhs: ServiceAddress) -> Bool {
        return lhs.id == rhs.id
    }
}
