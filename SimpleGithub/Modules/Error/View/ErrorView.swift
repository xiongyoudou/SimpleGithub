//
//  ContentView.swift
//  Shared
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

public struct ErrorView: View {
    @EnvironmentObject var store: Store<AppState>
    var state: HomeState? { store.state.screenState(for: .home) }

    var noEpisodesPlaceholder: some View {
        Text("Could not find episodes")
            .font(.title2)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(32.0)
    }

    var searchBar: some View {
        Text("")
            .searchable(
                text: Binding(get: { state?.searchText ?? "" }, set: { store.dispatch(HomeStateAction.filterEpisodes(phrase: $0)) }),
                placement: .navigationBarDrawer(displayMode: .always)
            )
            .disableAutocorrection(true)
    }

    public var body: some View {
        ZStack {
            searchBar
            
            if let state = state, !state.isLoading {
                if state.repos.isEmpty {
                    noEpisodesPlaceholder.animation(nil, value: UUID())
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
        .onLoad { store.dispatch(HomeStateAction.fetchRepos) }
    }

    private func createReposList() -> some View {
        List {
            ForEach(state?.repos ?? []) { repo in
                ZStack {
                    episodeRow(for: repo)
//                    navigation(for: repo)
                }.listRowSeparator(.hidden)
            }
        }.listStyle(.plain)
    }

    private func episodeRow(for repo: RepoItem) -> some View {
        RepoView(repoItem: repo)
            .cornerRadius(8.0)
            .padding(.bottom, 6.0)
            .padding(.horizontal, 6.0)
    }

//    private func navigation(for episode: RepoItem) -> some View {
//        NavigationLink(
//            isActive: Binding(
//                get: { episode.id == state?.presentedEpisodeId },
//                set: { isActive in
//                    let currentValue = episode.id == state?.presentedEpisodeId
//                    guard currentValue != isActive, !isActive else { return }
//                    store.dispatch(ActiveScreensStateAction.dismissScreen(.episode(id: episode.id)))
//                }
//            ),
//            destination: { EpisodeDetailsLoadingView(episodeId: episode.id) },
//            label: {}
//        ).hidden()
//    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ErrorView().environmentObject(store)
        }
    }
}
