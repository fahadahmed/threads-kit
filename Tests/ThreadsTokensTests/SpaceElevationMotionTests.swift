import SwiftUI
import Testing
@testable import ThreadsTokens

struct SpaceTests {
    @Test func namedStepsMatchTheHandoff() {
        #expect(ThreadsSpace.gutter == 26)
        #expect(ThreadsSpace.section == 22)
        #expect(ThreadsSpace.row == 14)             // the workhorse gap
        #expect(ThreadsSpace.tight == 10)
        #expect(ThreadsSpace.hair == 4)
    }

    @Test func paddingsAndRadii() {
        #expect(ThreadsSpace.rowPadding == EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
        #expect(ThreadsSpace.chipPadding == EdgeInsets(top: 9, leading: 20, bottom: 9, trailing: 20))
        #expect(ThreadsSpace.pillButtonPadding == EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
        #expect(ThreadsRadius.cell == 3)
        #expect(ThreadsRadius.field == 8)
        #expect(ThreadsRadius.card == 14)
    }

    @Test func theHitTargetIs44OnTouchAnd28ForAPointer() {
        #expect(ThreadsHit.minimum == 44)
        #expect(ThreadsHit.pointer == 28)
    }
}

struct ElevationTests {
    @Test func liftAndFloatInLight() {
        let lift = ThreadsElevation.lift.spec(for: .light)
        #expect((lift.y, lift.blur, lift.spread) == (18, 40, -26))
        #expect(lift.color == ThreadsShadowColor(red: 6, green: 32, blue: 46, alpha: 0.42))
        let float = ThreadsElevation.float.spec(for: .light)
        #expect((float.y, float.blur, float.spread) == (10, 26, -14))
        #expect(float.color == ThreadsShadowColor(red: 6, green: 32, blue: 46, alpha: 0.50))
    }

    @Test func darkUsesOneBlackShadowForBoth() {
        let black = ThreadsShadowColor(red: 0, green: 0, blue: 0, alpha: 0.70)
        for elevation in [ThreadsElevation.lift, .float] {
            let spec = elevation.spec(for: .dark)
            #expect((spec.y, spec.blur, spec.spread) == (22, 50, -28))
            #expect(spec.color == black)
        }
    }

    @Test func aHairlineHasNoShadowOnlyALine() {
        #expect(ThreadsElevation.hair.spec(for: .light).blur == 0)
        #expect(ThreadsElevation.hair.spec(for: .dark).y == 1)
    }

    @Test func swiftUIsShadowRadiusIsHalfTheCSSBlur() {
        #expect(ThreadsElevation.lift.spec(for: .light).shadowRadius == 20)
    }
}

struct MotionTests {
    @Test func twoDurationsAndOneCurve() {
        #expect(ThreadsMotion.stateDuration == 0.140)
        #expect(ThreadsMotion.surfaceDuration == 0.260)
        #expect(ThreadsMotion.curve == [0, 0, 0.2, 1])
    }

    @Test func reduceMotionMakesBothInstantAndRemovesTheAnimation() {
        #expect(ThreadsMotion.duration(.state, reduceMotion: false) == 0.140)
        #expect(ThreadsMotion.duration(.surface, reduceMotion: false) == 0.260)
        #expect(ThreadsMotion.duration(.state, reduceMotion: true) == 0)
        #expect(ThreadsMotion.duration(.surface, reduceMotion: true) == 0)
        #expect(ThreadsMotion.animation(.state, reduceMotion: true) == nil)
        #expect(ThreadsMotion.animation(.surface, reduceMotion: false) != nil)
    }
}
