//
//  AppStateReducer.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension AppState {
    static let reducer: Reducer<Self> = { state, action in
        AppState(
            loginState: LoginState.reducer(state.loginState,action),
            homeState: HomeState.reducer(state.homeState, action),
            userDetailsState: UserDetailsState.reducer(state.userDetailsState, action),
            errorState: ErrorState.reducer(state.errorState, action)
        )
    }
}
