//
//  ViewDidLoadModifier.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
    private let action: () -> Void

    @State private var didLoad = false

    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.onAppear {
            if !didLoad {
                didLoad.toggle()
                action()
            }
        }
    }
}
