//
//  UserDetailsView.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

struct UserDetailsView: View {
    let userId: UUID

    @EnvironmentObject var store: Store<AppState>
    var state: UserDetailsState? { store.state.screenState(for: .userProfile(id: userId)) }

    var body: some View {
        if let state = state, let userDetails = state.details, !state.isLoading {
            ScrollView {
                VStack(spacing: 8) {
                    Image(userDetails.avatar)
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)

                    Text(userDetails.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Joined: \(userDetails.signUpDate, format: .relative(presentation: .named))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Text("Location: \(userDetails.location)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(16.0)
                .padding(.top, 24.0)
            }
        } else {
            SpinnerView("Loading Profile")
                .onLoad { store.dispatch(UserDetailsStateAction.fetchUserProfile(userId: userId)) }
        }
    }
}

struct UserDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        UserDetailsView(userId: User.mock.id)
            .environmentObject(store)
    }
}
