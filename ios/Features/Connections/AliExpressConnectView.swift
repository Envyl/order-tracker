import SwiftUI

struct AliExpressConnectView: View {
    var onSubmit: (String, String, String?) async -> Void

    @State private var login = ""
    @State private var password = ""
    @State private var challenge = ""
    @State private var busy = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("AliExpress") {
                Text("Используйте уже существующий аккаунт AliExpress.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextField("Email или телефон", text: $login)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                SecureField("Пароль", text: $password)
                TextField("Код подтверждения (если запросили)", text: $challenge)
                    .keyboardType(.numberPad)
            }
            Section {
                Button("Подключить") {
                    Task {
                        busy = true
                        await onSubmit(
                            login,
                            password,
                            challenge.isEmpty ? nil : challenge
                        )
                        busy = false
                    }
                }
                .disabled(busy || login.isEmpty || password.isEmpty)
            }
        }
        .navigationTitle("Вход AliExpress")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Закрыть") { dismiss() }
            }
        }
        .disabled(busy)
    }
}
