import SwiftUI

struct OrderRowView: View {
    let order: Order

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            productImage
            VStack(alignment: .leading, spacing: 4) {
                Text(order.provider.displayName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(titleText)
                    .font(.body.weight(.medium))
                    .lineLimit(2)
                Text(order.status.labelRU)
                    .font(.subheadline)
                if order.isStale {
                    Text("Данные могут быть устаревшими")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
    }

    private var titleText: String {
        guard let primary = order.primaryItem else { return "Заказ \(order.providerOrderId)" }
        if order.extraItemCount > 0 {
            return "\(primary.title) и ещё \(order.extraItemCount)"
        }
        return primary.title
    }

    @ViewBuilder
    private var productImage: some View {
        if let url = order.primaryItem?.imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable().scaledToFill()
                default:
                    placeholder
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))
            Text("нет фото")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(width: 56, height: 56)
    }
}
