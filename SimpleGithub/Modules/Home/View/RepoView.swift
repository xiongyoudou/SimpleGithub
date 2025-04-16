//
//  UpcomingEpisodeView.swift
//  ReduxDemo
//
//  Created by Wojciech Kulik on 28/11/2021.
//

import SwiftUI

struct RepoView : View {
    let repoItem: GitHubRepo

    var headerView: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            Text(repoItem.name)
                .minimumScaleFactor(0.5)
                .font(.headline)
                .foregroundColor(.blue)

            Text("Description: " +
                 "\(repoItem.description ?? "")")
                .font(.footnote)
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
    }

    var body: some View {
        ZStack {
//            Color(white: 0.4, opacity: 1.0).ignoresSafeArea()
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    headerView
                    Spacer()
                    Spacer()
                }
                .padding(16)
                Spacer()
            }
            .background(.gray)
        }
        .lineLimit(1)
    }
}
