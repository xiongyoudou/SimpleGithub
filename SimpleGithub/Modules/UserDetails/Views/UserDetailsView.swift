//
//  UserDetailsView.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

struct UserDetailsView: View {
    @EnvironmentObject var store: Store<AppState>
    var state: UserDetailsState? { store.state.userDetailsState }
    var loginState: LoginState? {store.state.loginState}

    var body: some View {
        if let state = state, let userDetails = state.details, !state.isLoading {
            ScrollView {
                VStack(spacing: 8) {
                    AsyncImage(url: URL(string: userDetails.avatar_url)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if phase.error != nil {
                            Color.red
                        } else {
                            ProgressView()
                        }
                    }
                    .frame(width: 200, height: 200)
                    Text(userDetails.name ?? "")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(userDetails.email ?? "")
                        .font(.title2)
                }
                .padding(16.0)
                .padding(.top, 24.0)
            }
        } else {
            SpinnerView("Loading Profile")
                .onLoad {
                    store.dispatch(UserDetailsStateAction.fetchUserProfile(accessToken: loginState?.accessToken ?? ""))
                }
        }
    }
}
