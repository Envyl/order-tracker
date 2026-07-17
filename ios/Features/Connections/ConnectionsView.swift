import SwiftUI

struct ConnectionsView: View {
    @Environment(AppServices.self) private var services
    @State private var model: ConnectionsViewModel?
    @State private var route: ProviderId?

    var body: some View {
        List {
            Section {
                Text("Отдельный аккаунт Order Tracker не нужен — только привязка существующих учёток.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section("Провайдеры") {
                ForEach(model?.connections ?? []) { connection in
                    connectionRow(connection)
                }
            }

            if let error = model?.errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Подключения")
        .overlay {
            if model?.isWorking == true {
                ProgressView("Сохранение…")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .sheet(item: $route) { provider in
            NavigationStack {
                connectForm(for: provider)
            }
        }
        .onAppear {
            if model == nil {
                model = ConnectionsViewModel(services: services)
            } else {
                model?.reload()
            }
        }
    }

    @ViewBuilder
    private func connectionRow(_ connection: ProviderConnection) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(connection.provider.displayName)
                    .font(.headline)
                Spacer()
                Text(connection.status.labelRU)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(chipColor(connection.status).opacity(0.15))
                    .clipShape(Capsule())
            }
            if let hint = connection.displayLoginHint {
                Text(hint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let err = connection.lastErrorMessage, connection.status == .error || connection.status == .needsReauth {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            HStack {
                if connection.status == .disconnected || connection.status == .needsReauth || connection.status == .error {
                    Button(connection.status == .disconnected ? "Подключить" : "Обновить вход") {
                        route = connection.provider
                    }
                    .buttonStyle(.borderedProminent)
                }
                if connection.status != .disconnected {
                    Button("Отключить", role: .destructive) {
                        Task { await model?.disconnect(provider: connection.provider) }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func connectForm(for provider: ProviderId) -> some View {
        switch provider {
        case .wildberries:
            WildberriesConnectView { phone, sms, password in
                await model?.connect(
                    provider: .wildberries,
                    credentials: .wildberries(phone: phone, smsCode: sms, password: password)
                )
                if model?.errorMessage == nil { route = nil }
            }
        case .aliexpress:
            AliExpressConnectView { login, password, challenge in
                await model?.connect(
                    provider: .aliexpress,
                    credentials: .aliexpress(login: login, password: password, challengeCode: challenge)
                )
                if model?.errorMessage == nil { route = nil }
            }
        case .cdek:
            CDEKConnectView { login, code in
                await model?.connect(
                    provider: .cdek,
                    credentials: .cdek(login: login, codeOrPassword: code)
                )
                if model?.errorMessage == nil { route = nil }
            }
        }
    }

    private func chipColor(_ status: ConnectionStatus) -> Color {
        switch status {
        case .connected: return .green
        case .disconnected: return .gray
        case .needsReauth: return .orange
        case .error: return .red
        }
    }
}
