# ProgressiveBlur

A reusable, dependency-free progressive blur for SwiftUI, implemented as a Metal `layerEffect`.
Unlike the common "blur + gradient mask" trick, the sampling radius changes continuously across the view.

## Requirements

- iOS 17+
- macOS 14+
- tvOS 17+
- visionOS 1+
- Xcode 15+ (visionOS requires Xcode 15.2+ with the visionOS SDK)
- Swift 5.9+

## Installation

1. In Xcode, open your app project and choose **File → Add Package Dependencies…**.
2. Enter `https://github.com/Lian735/ProgressiveBlur.git`.
3. Select the `main` branch, or a version tag once a release is available.
4. Add the `ProgressiveBlur` library product to your app target.

Build this package through Xcode so its Metal resource is compiled into the package bundle.

Then:

```swift
import SwiftUI
import ProgressiveBlur
```

## Basic usage

```swift
Image("Hero")
    .resizable()
    .scaledToFill()
    .progressiveBlur(
        radius: 28,
        length: 160,
        direction: .topToBottom
    )
```

`radius` is the maximum blur strength. `length` is the physical transition distance in points.
For vertical directions, `length` behaves like a height. For horizontal directions, it behaves like a width.

## Vertical API (`height`)

```swift
content
    .progressiveVerticalBlur(
        radius: 30,
        height: 180,
        edge: .bottom
    )
```

## Horizontal API (`width`)

```swift
content
    .progressiveHorizontalBlur(
        radius: 24,
        width: 140,
        edge: .trailing
    )
```

## Start offset

Keep the first 50 points at full blur, then fade the blur over 160 points:

```swift
content
    .progressiveBlur(
        radius: 30,
        length: 160,
        direction: .topToBottom,
        start: 50
    )
```

## Curves

```swift
.progressiveBlur(
    radius: 30,
    length: 180,
    direction: .bottomToTop,
    curve: .smoothStep
)
```

Available curves:

- `.linear`
- `.easeIn`
- `.easeOut`
- `.smoothStep`

## Full API

```swift
.progressiveBlur(
    radius: 24,
    length: 120,
    direction: .topToBottom,
    start: 0,
    curve: .smoothStep,
    isEnabled: true
)
```

Directions:

- `.topToBottom`
- `.bottomToTop`
- `.leadingToTrailing`
- `.trailingToLeading`

## Notes

This modifier blurs the pixels rendered by the modified SwiftUI view. It is not a backdrop/material blur of unrelated views behind it.
The shader uses a 5×5 Gaussian sample grid and varies the sampling radius per pixel. The fixed grid uses up to 25 samples per pixel. Large radii may show repeated edges or undersampling; this is an approximation, not a full Gaussian convolution. Keep the modified region as small as practical.

Horizontal directions follow the environment’s layout direction, including right-to-left layouts.
Nonpositive radius/length and nonfinite parameters disable the effect. Toggling `isEnabled` preserves the view hierarchy.
SwiftUI layer effects may not render embedded UIKit/AppKit views correctly.

## License

MIT
