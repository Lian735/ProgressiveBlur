#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

static float blurCurve(float t, float curve) {
    t = clamp(t, 0.0, 1.0);
    if (curve < 0.5) {              // linear
        return t;
    } else if (curve < 1.5) {       // easeIn
        return t * t;
    } else if (curve < 2.5) {       // easeOut
        float u = 1.0 - t;
        return 1.0 - u * u;
    } else {                        // smoothStep
        return t * t * (3.0 - 2.0 * t);
    }
}

[[ stitchable ]] half4 progressiveBlur(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float maxRadius,
    float transitionLength,
    float start,
    float direction,
    float curve
) {
    float distanceFromEdge;

    if (direction < 0.5) {
        distanceFromEdge = position.y;                    // top -> bottom
    } else if (direction < 1.5) {
        distanceFromEdge = size.y - position.y;           // bottom -> top
    } else if (direction < 2.5) {
        distanceFromEdge = position.x;                    // left -> right (layout direction resolved in Swift)
    } else {
        distanceFromEdge = size.x - position.x;           // right -> left (layout direction resolved in Swift)
    }

    float progress = (distanceFromEdge - start) / max(transitionLength, 0.001);
    float fade = 1.0 - blurCurve(progress, curve);
    float radius = maxRadius * clamp(fade, 0.0, 1.0);

    if (radius < 0.35) {
        return layer.sample(position);
    }

    // 5x5 Gaussian-weighted sample grid. The kernel is Gaussian; its spatial radius changes
    // continuously per output pixel, which makes this a genuine variable/progressive blur rather
    // than a constant blur hidden behind a gradient mask.
    constexpr float weights[5] = { 0.06136, 0.24477, 0.38774, 0.24477, 0.06136 };
    constexpr float taps[5] = { -1.0, -0.5, 0.0, 0.5, 1.0 };

    half4 result = half4(0.0);
    float totalWeight = 0.0;

    for (int y = 0; y < 5; ++y) {
        for (int x = 0; x < 5; ++x) {
            float w = weights[x] * weights[y];
            float2 offset = float2(taps[x], taps[y]) * radius;
            result += layer.sample(position + offset) * half(w);
            totalWeight += w;
        }
    }

    return result / half(totalWeight);
}
