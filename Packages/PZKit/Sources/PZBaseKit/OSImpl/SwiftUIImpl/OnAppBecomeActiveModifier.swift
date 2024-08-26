// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

// MARK: - OnAppBecomeActiveModifier

/// A ViewModifier that adds an action to be performed whenever an app comes to active state.
private struct OnAppBecomeActiveModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// A closure that holds the action to be performed on becoming active.
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, scenePhase in
                if scenePhase == .active {
                    action()
                }
            }
    }
}

// MARK: - OnAppEnterBackgroundModifier

/// A ViewModifier that adds an action to be performed whenever an app enters background state.
private struct OnAppEnterBackgroundModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// A closure that holds the action to be performed on entering the background state.
    let action: () -> Void

    /// The view body with the added action.
    /// - Parameter content: The Content view.
    /// - Returns: A view with the added action.
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, scenePhase in
                if scenePhase == .background {
                    action()
                }
            }
    }
}

// MARK: - OnAppBecomeInactiveModifier

/// A ViewModifier that adds an action to be performed whenever an app becomes inactive.
private struct OnAppBecomeInactiveModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// A closure that holds the action to be performed on becoming inactive.
    let action: () -> Void

    /// The view body with the added action.
    /// - Parameter content: The Content view.
    /// - Returns: A view with the added action.
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, scenePhase in
                if scenePhase == .inactive {
                    action()
                }
            }
    }
}

extension View {
    /// Add an action to be performed whenever an app comes to active state.
    ///
    /// - Parameter action: A closure that holds the action to be performed on becoming active.
    /// - Returns: A View with the added action.
    public func onAppBecomeActive(perform action: @escaping () -> Void) -> some View {
        modifier(OnAppBecomeActiveModifier(action: action))
    }

    /// Add an action to be performed whenever an app enters background state.
    ///
    /// - Parameter action: A closure that holds the action to be performed on entering the background state.
    /// - Returns: A View with the added action.
    public func onAppEnterBackground(perform action: @escaping () -> Void) -> some View {
        modifier(OnAppEnterBackgroundModifier(action: action))
    }

    /// Add an action to be performed whenever an app becomes inactive.
    ///
    /// - Parameter action: A closure that holds the action to be performed on becoming inactive.
    /// - Returns: A View with the added action.
    public func onAppBecomeInactive(perform action: @escaping () -> Void) -> some View {
        modifier(OnAppBecomeInactiveModifier(action: action))
    }
}