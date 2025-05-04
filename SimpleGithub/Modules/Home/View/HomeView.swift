//
//  ContentView.swift
//  Shared
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

public struct HomeView: View {
    @EnvironmentObject var store: Store<AppState>
    var state: HomeState? { store.state.homeState }
    var loginState: LoginState? {store.state.loginState}

    var noReposPlaceholder: some View {
        Text("Could not find episodes")
            .font(.title2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(32.0)
    }

    var searchBar: some View {
        Text("")
            .searchable(
                text: Binding(get: { state?.searchText ?? "" }, set: { store.dispatch(HomeStateAction.filterRepos(phrase: $0)) }),
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .disableAutocorrection(true)
    }

    public var body: some View {
        ZStack {
            searchBar
            
            if let state = state, !state.isLoading {
                if state.repos.isEmpty {
                    noReposPlaceholder.animation(nil, value: UUID())
                } else {
                    createReposList()
                }
            } else {
                SpinnerView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Repos")
        .addProfileButton()
        .onLoad { store.dispatch(HomeStateAction.fetchRepos(accessToken: loginState?.accessToken ?? "")) }
    }

    private func createReposList() -> some View {
        List {
            ForEach(state?.filterRepos ?? []) { repo in
                ZStack {
                    episodeRow(for: repo)
                }.listRowSeparator(.hidden)
            }
        }.listStyle(.plain)
    }

    private func episodeRow(for repo: GitHubRepo) -> some View {
        RepoView(repoItem: repo)
            .cornerRadius(8.0)
            .padding(.bottom, 6.0)
            .padding(.horizontal, 6.0)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView().environmentObject(store)
        }
    }
}
