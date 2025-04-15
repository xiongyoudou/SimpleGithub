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
        case HomeStateAction.fetchRepos:
            return HomeState(
                repos: [],
                isLoading: true,
                searchText: state.searchText
            )
        case HomeStateAction.didReceiveRepos(let repos):
            return HomeState(
                repos: repos,
                isLoading: false,
                searchText: state.searchText
            )
        case HomeStateAction.filterEpisodes(let phrase), HomeStateAction.updateSearchText(let phrase):
            return HomeState(
                repos: state.repos,
                isLoading: phrase != "",
                searchText: phrase
            )
        default:
            return state
        }
    }
}
