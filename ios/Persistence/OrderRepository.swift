import Foundation
import SwiftData

@MainActor
final class OrderRepository {
    private let context: ModelContext
    private let horizonDays: Int

    init(context: ModelContext, horizonDays: Int = 30) {
        self.context = context
        self.horizonDays = horizonDays
    }

    func allVisible() -> [Order] {
        let cutoff = Calendar.current.date(byAdding: .day, value: -horizonDays, to: Date()) ?? Date.distantPast
        let descriptor = FetchDescriptor<SDOrder>(
            sortBy: [SortDescriptor(\.lastUpdatedAt, order: .reverse)]
        )
        let rows = (try? context.fetch(descriptor)) ?? []
        return rows
            .filter { order in
                order.fetchedAt >= cutoff || ![OrderStatus.delivered, .cancelled].contains(order.status)
            }
            .map(map)
    }

    func order(id: UUID) -> Order? {
        allVisible().first { $0.id == id }
    }

    func upsert(provider: ProviderId, drafts: [NormalizedOrderDraft], markStaleOthers: Bool) throws {
        let now = Date()
        let seen = Set(drafts.map(\.providerOrderId))

        for draft in drafts {
            let existing = find(provider: provider, providerOrderId: draft.providerOrderId)
            let row = existing ?? SDOrder(
                provider: provider,
                providerOrderId: draft.providerOrderId,
                status: draft.status,
                statusRawLabel: draft.statusRawLabel,
                lastUpdatedAt: draft.lastUpdatedAt,
                fetchedAt: now,
                isStale: false
            )
            if existing == nil {
                context.insert(row)
            }
            row.statusRaw = draft.status.rawValue
            row.statusRawLabel = draft.statusRawLabel
            row.lastUpdatedAt = draft.lastUpdatedAt
            row.fetchedAt = now
            row.isStale = false

            row.items.forEach { context.delete($0) }
            row.items = draft.items.enumerated().map { index, item in
                SDOrderItem(
                    title: item.title,
                    imageURL: item.imageURL,
                    sortIndex: index,
                    quantity: item.quantity
                )
            }

            let snap = SDStatusSnapshot(
                status: draft.status,
                rawLabel: draft.statusRawLabel,
                recordedAt: now
            )
            row.snapshots.append(snap)
        }

        if markStaleOthers {
            let allForProvider = fetchAll(provider: provider)
            for row in allForProvider where !seen.contains(row.providerOrderId) {
                // Keep recently fetched rows; do not auto-delete
                _ = row
            }
        }

        try context.save()
    }

    func markStale(provider: ProviderId) throws {
        for row in fetchAll(provider: provider) {
            row.isStale = true
        }
        try context.save()
    }

    private func find(provider: ProviderId, providerOrderId: String) -> SDOrder? {
        let raw = provider.rawValue
        let descriptor = FetchDescriptor<SDOrder>(
            predicate: #Predicate { $0.providerRaw == raw && $0.providerOrderId == providerOrderId }
        )
        return try? context.fetch(descriptor).first
    }

    private func fetchAll(provider: ProviderId) -> [SDOrder] {
        let raw = provider.rawValue
        let descriptor = FetchDescriptor<SDOrder>(
            predicate: #Predicate { $0.providerRaw == raw }
        )
        return (try? context.fetch(descriptor)) ?? []
    }

    private func map(_ row: SDOrder) -> Order {
        let items = row.items
            .sorted { $0.sortIndex < $1.sortIndex }
            .map {
                OrderItem(
                    id: $0.id,
                    title: $0.title,
                    imageURL: $0.imageURLString.flatMap(URL.init(string:)),
                    sortIndex: $0.sortIndex,
                    quantity: $0.quantity
                )
            }
        let latest = row.snapshots.sorted { $0.recordedAt > $1.recordedAt }.first.map {
            StatusSnapshot(id: $0.id, status: $0.status, rawLabel: $0.rawLabel, recordedAt: $0.recordedAt)
        }
        return Order(
            id: row.id,
            provider: row.provider,
            providerOrderId: row.providerOrderId,
            status: row.status,
            statusRawLabel: row.statusRawLabel,
            lastUpdatedAt: row.lastUpdatedAt,
            fetchedAt: row.fetchedAt,
            isStale: row.isStale,
            items: items,
            latestSnapshot: latest
        )
    }
}
