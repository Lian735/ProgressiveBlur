import SwiftUI
import XCTest
@testable import ProgressiveBlur

final class ProgressiveBlurTests: XCTestCase {
    func testHorizontalDirectionsFollowLayoutDirection() {
        XCTAssertEqual(ProgressiveBlurDirection.leadingToTrailing.shaderValue(layoutDirection: .leftToRight), 2)
        XCTAssertEqual(ProgressiveBlurDirection.leadingToTrailing.shaderValue(layoutDirection: .rightToLeft), 3)
        XCTAssertEqual(ProgressiveBlurDirection.trailingToLeading.shaderValue(layoutDirection: .leftToRight), 3)
        XCTAssertEqual(ProgressiveBlurDirection.trailingToLeading.shaderValue(layoutDirection: .rightToLeft), 2)
    }

    func testVerticalDirectionsAreIndependentOfLayoutDirection() {
        for layout in [LayoutDirection.leftToRight, .rightToLeft] {
            XCTAssertEqual(ProgressiveBlurDirection.topToBottom.shaderValue(layoutDirection: layout), 0)
            XCTAssertEqual(ProgressiveBlurDirection.bottomToTop.shaderValue(layoutDirection: layout), 1)
        }
    }
}
