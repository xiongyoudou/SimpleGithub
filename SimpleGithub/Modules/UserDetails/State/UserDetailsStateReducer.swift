//
//  UserDetailsStateReducer.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension UserDetailsState {
    static let reducer: Reducer<Self> = { state, action in
        guard let action = action as? UserDetailsStateAction else { return state }

        switch action {
        case .fetchUserProfile(let token):
            return UserDetailsState(
                details: nil,
                isLoading: true
            )
        case .didReceiveUserProfile(let userDetails):
            return UserDetailsState(
                details: userDetails,
                isLoading: false
            )
        }
    }
}
