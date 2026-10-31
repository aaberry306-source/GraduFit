import SwiftUI

struct PrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title).font(.headline)
                Image(systemName: "arrow.right").accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: GraduFitTheme.minimumControlHeight)
            .padding(.vertical, 3)
            .foregroundStyle(isEnabled ? Color.white : GraduFitTheme.secondaryText)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isEnabled ? GraduFitTheme.blue : Color(red: 0.85, green: 0.87, blue: 0.90))
            }
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}
