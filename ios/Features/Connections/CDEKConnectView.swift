import SwiftUI

struct CDEKConnectView: View {
    var onSubmit: (String, String) async -> Void

    @State private var login = ""
    @State private var codeOrPassword = ""
    @State private var busy = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("СДЭК") {
                Text("Подключите личный кабинет СДЭК. Трекинг без аккаунта в этой версии не используется.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextField("Телефон или логин", text: $login)
                    .textInputAutocapitalization(.never)
                SecureField("Код или пароль", text: $codeOrPassword)
            }
            Section {
                Button("Подключить") {
                    Task {
                        busy = true
                        await onSubmit(login, codeOrPassword)
                        busy = false
                    }
                }
                .disabled(busy || login.isEmpty || codeOrPassword.isEmpty)
            }
        }
        .navigationTitle("Вход СДЭК")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Закрыть") { dismiss() }
            }
        }
        .disabled(busy)
    }
}
