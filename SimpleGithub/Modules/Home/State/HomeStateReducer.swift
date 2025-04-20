//
//  HomeStateReducer.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation

extension HomeState {
    static let reducer: Reducer<Self> = { state, action in
        guard let action = action as? HomeStateAction else { return state }
        
        switch action {
        case HomeStateAction.fetchRepos(let accessToken):
            return HomeState(
                repos: [],
                filterRepos: [],
                isLoading: true,
                searchText: state.searchText
            )
        case HomeStateAction.didReceiveRepos(let repos):
            return HomeState(
                repos: repos,
                filterRepos: repos,
                isLoading: false,
                searchText: state.searchText
            )
        case HomeStateAction.filterRepos(let phrase):
            let filteredRepos = state.repos.filter { repo in
                phrase.isEmpty || repo.name.localizedCaseInsensitiveContains(phrase)
            }
            return HomeState(
                repos: state.repos,
                filterRepos: filteredRepos,
                isLoading: false,
                searchText: phrase
            )
        }
    }
}
