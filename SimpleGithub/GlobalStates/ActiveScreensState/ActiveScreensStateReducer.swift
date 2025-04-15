//
//  ActiveScreensStateReducer.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension ActiveScreensState {
    static let reducer: Reducer<Self> = { state, action in
        var screens = state.screens

        // Update visible screens
        if let action = action as? ActiveScreensStateAction {
            switch action {
            case .showScreen(.login): screens = [.login(LoginState())]
            case .showScreen(.home): screens = [.home(HomeState())]
            case .showScreen(.userProfile(let id)): screens += [.userProfile(UserDetailsState(id: id))]
            case .showScreen(.error): screens = [.error(ErrorState())]
            case .dismissScreen(let screen): screens = screens.filter { $0 != screen }
            }
        }

        // Reduce each screen state
        screens = screens.map { AppScreenState.reducer($0, action) }

        return ActiveScreensState(screens: screens)
    }
}
