//
//  View+Modifiers.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

extension View {
    func onLoad(_ action: @escaping () -> Void) -> some View {
        modifier(ViewDidLoadModifier(action))
    }

    func addProfileButton() -> some View {
        modifier(ProfileButtonModifier())
    }
}
