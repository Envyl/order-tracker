import SwiftUI

struct ProviderStatusBanner: View {
    let messages: [String]
    var onOpenConnections: () -> Void

    var body: some View {
        if !messages.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(messages, id: \.self) { message in
                    Text(message)
                        .font(.footnote)
                }
                Button("Открыть подключения", action: onOpenConnections)
                    .font(.footnote.weight(.semibold))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Color.orange.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
}
