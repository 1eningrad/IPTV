import SwiftUI
import UIKit

struct SettingsView: View {
    @State private var appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    @State private var appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "N/A"
    @State private var isPasswordProtected = false
    @State private var bufferValue: Float = 1.0
    @State private var selectedDecoder = 0
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о приложении")) {
                    HStack {
                        Text("Версия")
                        Spacer()
                        Text(appVersion)
                    }
                    HStack {
                        Text("Сборка")
                        Spacer()
                        Text(appBuild)
                    }
                }
                
                Section(header: Text("Настройки")) {
                    Toggle("Защита паролем", isOn: $isPasswordProtected)
                    HStack {
                        Text("Размер буфера")
                        Slider(value: $bufferValue, in: 0...2, step: 0.1)
                        Text("\(bufferValue, specifier: "%.1f")")
                    }
                    Picker("Декодирование", selection: $selectedDecoder) {
                        Text("Автоматическое").tag(0)
                        Text("Аппаратное").tag(1)
                        Text("Программное").tag(2)
                    }
                    Toggle("Темная тема", isOn: $isDarkMode)
                }
            }
            .navigationBarTitle("Настройки")
            .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .onAppear {
            isDarkMode = colorScheme == .dark
        }
    }
}
