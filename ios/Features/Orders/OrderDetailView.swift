import SwiftUI

struct OrderDetailView: View {
    @Environment(AppServices.self) private var services
    let orderID: UUID
    @State private var model: OrderDetailViewModel?

    var body: some View {
        Group {
            if let order = model?.order {
                detail(order)
            } else {
                ContentUnavailableView("Заказ не найден", systemImage: "questionmark.circle")
            }
        }
        .navigationTitle("Детали")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if model == nil {
                model = OrderDetailViewModel(services: services, orderID: orderID)
            } else {
                model?.reload()
            }
        }
    }

    @ViewBuilder
    private func detail(_ order: Order) -> some View {
        List {
            Section("Провайдер") {
                Text(order.provider.displayName)
            }

            Section("Товар") {
                HStack(alignment: .top, spacing: 12) {
                    detailImage(order)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(order.primaryItem?.title ?? "Без названия")
                            .font(.headline)
                        if order.extraItemCount > 0 {
                            Text("и ещё \(order.extraItemCount)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Статус") {
                Text(order.status.labelRU)
                if let raw = order.statusRawLabel, order.status == .unknown || raw != order.status.labelRU {
                    Text(raw)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if order.isStale || order.status == .unknown {
                    Text(order.isStale
                           ? "Данные устарели или получены из кэша. Статус не выдуман."
                           : "Точный статус неизвестен — показан как есть.")
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }
            }

            Section("Служебное") {
                LabeledContent("ID", value: order.providerOrderId)
                LabeledContent(
                    "Обновлено",
                    value: order.lastUpdatedAt.formatted(date: .abbreviated, time: .shortened)
                )
            }
        }
    }

    @ViewBuilder
    private func detailImage(_ order: Order) -> some View {
        if let url = order.primaryItem?.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholder
                }
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.secondary.opacity(0.15))
            Text("нет фото")
                .font(.caption2)
        }
        .frame(width: 72, height: 72)
    }
}
