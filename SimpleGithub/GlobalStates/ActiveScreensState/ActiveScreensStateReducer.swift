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
            case .showScreen(.login): screens = [.login]
            case .showScreen(.home): screens = [.home(HomeState())]
            case .showScreen(.userProfile): screens += [.userProfile(UserDetailsState())]
            case .showScreen(.error): screens = [.error(ErrorState())]
            case .dismissScreen(let screen): screens = screens.filter { $0 != screen }
            }
        } else if let action = action as? HomeStateAction {
            var homeState = state.homeScreenState(for: .home)
            screens = [.home(homeState ?? HomeState())]
        } else if let action = action as? UserDetailsStateAction {
            screens = [.userProfile(UserDetailsState())]
        }
        
        


        // Reduce each screen state
        screens = screens.map { AppScreenState.reducer($0, action) }

        return ActiveScreensState(screens: screens)
    }
}
