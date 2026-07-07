import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var purchases: PurchaseManager

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 48))
                    .foregroundStyle(Theme.accent)
                Text("Thank-You Tracker Export")
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.textPrimary)
                Text("Thank-you-note sent tracker and export list")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let product = purchases.product {
                    Button {
                        Task { await purchases.purchase() }
                    } label: {
                        Text("Subscribe — \(product.displayPrice)/month")
                            .font(Theme.bodyFont.weight(.bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .accessibilityIdentifier("subscribeButton")
                    .padding(.horizontal)
                } else {
                    ProgressView()
                }

                Button("Restore Purchases") {
                    Task { await purchases.restore() }
                }
                .accessibilityIdentifier("paywallRestoreButton")

                Button("Not now") { dismiss() }
                    .foregroundStyle(Theme.textSecondary)
                    .accessibilityIdentifier("paywallDismissButton")
            }
            .padding()
        }
        .task { await purchases.load() }
    }
}
