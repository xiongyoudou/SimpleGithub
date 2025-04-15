//
//  AppState+ScreenStateSelector.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension AppState {
    func screenState<State>(for screen: AppScreen) -> State? {
        return activeScreens.screens
            .compactMap {
                switch ($0, screen) {
                case (.home(let state), .home): return state as? State
                case (.userProfile(let state), .userProfile(let id)) where state.userId == id: return state as? State
                default: return nil
                }
            }
            .first
    }
}
