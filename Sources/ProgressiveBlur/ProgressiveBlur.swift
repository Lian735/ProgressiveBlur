import SwiftUI

/// The edge from which a progressive blur is measured.
public enum ProgressiveBlurDirection: Sendable, Hashable {
    case topToBottom
    case bottomToTop
    case leadingToTrailing
    case trailingToLeading

    func shaderValue(layoutDirection: LayoutDirection) -> Float {
        switch self {
        case .topToBottom: 0
        case .bottomToTop: 1
        case .leadingToTrailing: layoutDirection == .rightToLeft ? 3 : 2
        case .trailingToLeading: layoutDirection == .rightToLeft ? 2 : 3
        }
    }
}

/// Controls how quickly the blur falls from its maximum radius to zero.
public enum ProgressiveBlurCurve: Sendable, Hashable {
    case linear
    case easeIn
    case easeOut
    case smoothStep

    fileprivate var shaderValue: Float {
        switch self {
        case .linear: 0
        case .easeIn: 1
        case .easeOut: 2
        case .smoothStep: 3
        }
    }
}

public extension View {
    /// Applies a true spatially-varying blur to this view using a SwiftUI Metal layer effect.
    ///
    /// - Parameters:
    ///   - radius: Maximum blur radius in points.
    ///   - length: Distance in points over which the blur transitions from `radius` to zero.
    ///             For vertical directions this is a height; for horizontal directions it is a width.
    ///   - direction: Edge and direction of the transition.
    ///   - start: Distance from the selected edge before the fade begins. The area before `start`
    ///            remains at the maximum blur radius.
    ///   - curve: Shape of the blur falloff.
    ///   - isEnabled: Set to `false` to bypass the effect without changing the view hierarchy.
    @ViewBuilder
    func progressiveBlur(
        radius: CGFloat = 24,
        length: CGFloat = 120,
        direction: ProgressiveBlurDirection = .topToBottom,
        start: CGFloat = 0,
        curve: ProgressiveBlurCurve = .smoothStep,
        isEnabled: Bool = true
    ) -> some View {
        modifier(ProgressiveBlurModifier(
            radius: radius,
            length: length,
            direction: direction,
            start: start,
            curve: curve,
            isEnabled: isEnabled
        ))
    }

    /// Convenience API for a vertical progressive blur. `height` is the transition length.
    func progressiveVerticalBlur(
        radius: CGFloat = 24,
        height: CGFloat = 120,
        edge: VerticalEdge = .top,
        start: CGFloat = 0,
        curve: ProgressiveBlurCurve = .smoothStep,
        isEnabled: Bool = true
    ) -> some View {
        progressiveBlur(
            radius: radius,
            length: height,
            direction: edge == .top ? .topToBottom : .bottomToTop,
            start: start,
            curve: curve,
            isEnabled: isEnabled
        )
    }

    /// Convenience API for a horizontal progressive blur. `width` is the transition length.
    func progressiveHorizontalBlur(
        radius: CGFloat = 24,
        width: CGFloat = 120,
        edge: HorizontalEdge = .leading,
        start: CGFloat = 0,
        curve: ProgressiveBlurCurve = .smoothStep,
        isEnabled: Bool = true
    ) -> some View {
        progressiveBlur(
            radius: radius,
            length: width,
            direction: edge == .leading ? .leadingToTrailing : .trailingToLeading,
            start: start,
            curve: curve,
            isEnabled: isEnabled
        )
    }
}

private struct ProgressiveBlurModifier: ViewModifier {
    @Environment(\.layoutDirection) private var layoutDirection

    let radius: CGFloat
    let length: CGFloat
    let direction: ProgressiveBlurDirection
    let start: CGFloat
    let curve: ProgressiveBlurCurve
    let isEnabled: Bool

    func body(content: Content) -> some View {
        let enabled = isEnabled && radius > 0 && length > 0
            && Float(radius).isFinite && Float(length).isFinite && Float(start).isFinite
        let sampleRadius = enabled ? radius : 0
        let shaderDirection = direction.shaderValue(layoutDirection: layoutDirection)

        content.visualEffect { effect, proxy in
            effect.layerEffect(
                ShaderLibrary.bundle(.module).progressiveBlur(
                    .float2(Float(proxy.size.width), Float(proxy.size.height)),
                    .float(Float(sampleRadius)),
                    .float(enabled ? Float(length) : 1),
                    .float(enabled ? Float(start) : 0),
                    .float(shaderDirection),
                    .float(curve.shaderValue)
                ),
                maxSampleOffset: CGSize(width: sampleRadius, height: sampleRadius),
                isEnabled: enabled
            )
        }
    }
}
