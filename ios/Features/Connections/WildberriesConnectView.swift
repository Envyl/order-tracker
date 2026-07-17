import SwiftUI

struct WildberriesConnectView: View {
    var onSubmit: (String, String?, String?) async -> Void

    @State private var phone = ""
    @State private var smsCode = ""
    @State private var password = ""
    @State private var busy = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("Wildberries") {
                Text("Войдите существующим аккаунтом. Новую регистрацию здесь создать нельзя.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                TextField("Телефон", text: $phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                TextField("Код из SMS", text: $smsCode)
                    .keyboardType(.numberPad)
                SecureField("Пароль (если используется)", text: $password)
            }
            Section {
                Button("Подключить") {
                    Task {
                        busy = true
                        await onSubmit(
                            phone,
                            smsCode.isEmpty ? nil : smsCode,
                            password.isEmpty ? nil : password
                        )
                        busy = false
                    }
                }
                .disabled(busy || phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Вход WB")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Закрыть") { dismiss() }
            }
        }
        .disabled(busy)
    }
}
