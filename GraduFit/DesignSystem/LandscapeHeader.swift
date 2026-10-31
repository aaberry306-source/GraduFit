import SwiftUI

/// Original scalable placeholder artwork; replace with the approved production asset.
/// Branding is rendered separately so it stays sharp and supports accessibility.
struct LandscapeHeader: View {
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let size = geometry.size
                ZStack {
                    LinearGradient(colors: [Color(red: 0.61, green: 0.79, blue: 0.94),
                                            Color(red: 0.91, green: 0.95, blue: 0.94)],
                                   startPoint: .top, endPoint: .bottom)
                    Circle()
                        .fill(Color(red: 1, green: 0.95, blue: 0.79))
                        .frame(width: 72, height: 72)
                        .blur(radius: 7)
                        .position(x: size.width * 0.82, y: size.height * 0.38)
                    LandscapeHill(crest: 0.44, valley: 0.60)
                        .fill(Color(red: 0.61, green: 0.76, blue: 0.86))
                    LandscapeHill(crest: 0.65, valley: 0.51)
                        .fill(Color(red: 0.45, green: 0.65, blue: 0.73).opacity(0.7))
                    LandscapeHill(crest: 0.77, valley: 0.80)
                        .fill(Color(red: 0.66, green: 0.76, blue: 0.57))
                    Path { path in
                        path.move(to: CGPoint(x: size.width * 0.48, y: size.height))
                        path.addCurve(to: CGPoint(x: size.width * 0.82, y: size.height * 0.72),
                                      control1: CGPoint(x: size.width * 1.25, y: size.height * 0.80),
                                      control2: CGPoint(x: size.width * 0.96, y: size.height * 0.79))
                    }
                    .stroke(Color(red: 1, green: 0.94, blue: 0.76), style: StrokeStyle(lineWidth: 16))
                    ForEach(0..<8) { index in
                        let isLeft = index < 4
                        Image(systemName: "tree.fill")
                            .font(.system(size: CGFloat(75 - (index % 4) * 9)))
                            .foregroundStyle(Color(red: 0.21, green: 0.43, blue: 0.43).opacity(0.78))
                            .position(x: isLeft ? CGFloat(index) * 15 : size.width - CGFloat(index - 4) * 16,
                                      y: size.height * 0.68 + CGFloat(index % 3) * 16)
                    }
                }
            }
            .accessibilityHidden(true)

            VStack(spacing: 8) {
                ZStack(alignment: .top) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 58, weight: .bold))
                        .padding(.top, 12)
                    Image(systemName: "graduationcap.fill")
                        .font(.system(size: 25))
                        .offset(x: 9, y: -2)
                }
                .foregroundStyle(.white)
                .shadow(color: GraduFitTheme.ink.opacity(0.18), radius: 5, y: 3)
                .accessibilityHidden(true)

                Text("GraduFit")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(GraduFitTheme.ink)
                    .accessibilityAddTraits(.isHeader)
                Text("MOVE · LEARN · PROGRESS")
                    .font(.caption.weight(.semibold))
                    .tracking(2)
                    .foregroundStyle(GraduFitTheme.ink)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 22)
        }
        .clipped()
    }
}

private struct LandscapeHill: Shape {
    let crest: CGFloat
    let valley: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: rect.height * crest))
            path.addCurve(to: CGPoint(x: rect.width, y: rect.height * valley),
                          control1: CGPoint(x: rect.width * 0.30, y: rect.height * (crest - 0.24)),
                          control2: CGPoint(x: rect.width * 0.65, y: rect.height * (valley + 0.15)))
            path.addLine(to: CGPoint(x: rect.width, y: rect.height))
            path.addLine(to: CGPoint(x: 0, y: rect.height))
            path.closeSubpath()
        }
    }
}
