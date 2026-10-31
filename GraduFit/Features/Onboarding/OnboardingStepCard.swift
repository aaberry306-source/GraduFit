import SwiftUI

struct OnboardingStepCard<Content: View>: View {
    let title: String
    let subtitle: String
    let symbol: String
    let tint: Color
    let fill: Color
    let isExpanded: Bool
    let isComplete: Bool
    let isAvailable: Bool
    let accessibilityID: String
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: action) {
                HStack(spacing: 14) {
                    Image(systemName: symbol)
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundStyle(tint)
                        .frame(width: 52, height: 52)
                        .background(tint.opacity(0.10), in: Circle())
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(title)
                            .font(.headline)
                            .foregroundStyle(GraduFitTheme.ink)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(GraduFitTheme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Image(systemName: isComplete ? "checkmark.circle.fill" : (isExpanded ? "chevron.up" : "chevron.down"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(isComplete ? GraduFitTheme.green : GraduFitTheme.secondaryText)
                        .accessibilityHidden(true)
                }
                .padding(14)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!isAvailable)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(title). \(subtitle)")
            .accessibilityValue(isComplete ? "Complete" : (isExpanded ? "Expanded, incomplete" : "Collapsed, incomplete"))
            .accessibilityHint(isAvailable ? "Double tap to \(isExpanded ? "collapse" : "expand")" : "Available in a later module")
            .accessibilityIdentifier(accessibilityID)

            if isExpanded {
                content()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .background(fill, in: RoundedRectangle(cornerRadius: GraduFitTheme.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: GraduFitTheme.cardRadius)
                .strokeBorder(tint.opacity(0.12), lineWidth: 1)
        }
    }
}
