import SwiftUI

struct UserSettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Внешний вид")) {
                    Toggle("Темная тема", isOn: $isDarkMode)
                }
            }
            .navigationTitle("Настройки пользователя")
        }
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView()
    }
}
