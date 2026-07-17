import SwiftUI

struct OrdersListView: View {
    @Environment(AppServices.self) private var services
    @State private var model: OrdersListViewModel?

    var body: some View {
        Group {
            if let model {
                content(model)
            } else {
                ProgressView()
                    .onAppear { model = OrdersListViewModel(services: services) }
            }
        }
    }

    @ViewBuilder
    private func content(_ model: OrdersListViewModel) -> some View {
        VStack(spacing: 0) {
            if !model.bannerMessages.isEmpty {
                ProviderStatusBanner(messages: model.bannerMessages) {}
                NavigationLink("Исправить подключения") {
                    ConnectionsView()
                }
                .padding(.horizontal)
                .padding(.bottom, 4)
            }

            List {
                if let last = model.lastRefreshAt {
                    Section {
                        Text("Обновлено: \(last.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                if model.orders.isEmpty {
                    Section {
                        ContentUnavailableView(
                            "Пока нет заказов",
                            systemImage: "shippingbox",
                            description: Text("Подключите провайдеров и обновите список.")
                        )
                    }
                } else {
                    Section("Заказы") {
                        ForEach(model.orders) { order in
                            NavigationLink {
                                OrderDetailView(orderID: order.id)
                            } label: {
                                OrderRowView(order: order)
                            }
                        }
                    }
                }
            }
            .listStyle(.plain)
            .refreshable {
                await model.refresh()
            }
        }
        .navigationTitle("Order Tracker")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink("Подключения") {
                    ConnectionsView()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task { await model.refresh() }
                } label: {
                    if model.isRefreshing {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear { model.reload() }
    }
}
