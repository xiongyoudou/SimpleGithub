//
//  HomeStateReducer.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension HomeState {
    static let reducer: Reducer<Self> = { state, action in
        switch action {
        case HomeStateAction.updateAccessToken(let accessToken):
            return HomeState(
                repos: [],
                isLoading: state.isLoading,
                searchText: state.searchText,
                accessToken: accessToken
            )
        case HomeStateAction.fetchRepos(let accessToken):
            return HomeState(
                repos: [],
                isLoading: true,
                searchText: state.searchText,
                accessToken: state.accessToken
            )
        case HomeStateAction.didReceiveRepos(let repos):
            return HomeState(
                repos: repos,
                isLoading: false,
                searchText: state.searchText,
                accessToken: state.accessToken
            )
//        case HomeStateAction.filterRepos(let accessToken, let phrase), HomeStateAction.updateSearchText(let phrase):
//            return HomeState(
//                repos: state.repos,
//                isLoading: phrase != "",
//                searchText: phrase
//            )
        default:
            return state
        }
    }
}
