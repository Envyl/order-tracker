import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            OrdersListView()
        }
    }
}

#Preview {
    RootView()
        .environment(AppServices())
}
