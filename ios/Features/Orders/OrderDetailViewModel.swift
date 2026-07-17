import Foundation

@MainActor
@Observable
final class OrderDetailViewModel {
    private let services: AppServices
    let orderID: UUID
    var order: Order?

    init(services: AppServices, orderID: UUID) {
        self.services = services
        self.orderID = orderID
        reload()
    }

    func reload() {
        order = services.orders.order(id: orderID)
    }
}
