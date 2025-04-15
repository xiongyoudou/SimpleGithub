//
//  ReplayButtonModifier.swift
//  SimpleGithub
//
//  Created by Wojciech Kulik on 02/12/2021.
//

import Foundation
import SwiftUI

struct ProfileButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.toolbar(content: {
            ToolbarItem {
                Button(action: {
                    print("click me")
                }) {
                    NavigationLink(destination: UserDetailsView(userId: UUID())) {
                        Image(systemName: "person.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        })
    }
}
