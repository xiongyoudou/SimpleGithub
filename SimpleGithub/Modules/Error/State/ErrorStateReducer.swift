//
//  AppStateReducer.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension ErrorState {
    static let reducer: Reducer<Self> = { state, action in
        guard let action = action as? ErrorStateAction else { return state }

        return state
    }
}
