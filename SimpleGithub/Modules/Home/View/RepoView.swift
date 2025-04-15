//
//  UpcomingEpisodeView.swift
//  ReduxDemo
//
//  Created by Wojciech Kulik on 28/11/2021.
//

import SwiftUI

struct RepoView : View {
    let repoItem: RepoItem

//    var posterView: some View {
//        Image(repoItem.s)
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(maxWidth: 120.0)
//    }

    var headerView: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            Text(repoItem.name)
                .minimumScaleFactor(0.5)
                .font(.headline)

            Text("Next episode: " +
                "\(repoItem.description)")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
    }

    var body: some View {
        ZStack {
            Color(white: 0.1, opacity: 1.0).ignoresSafeArea()
            HStack {
//                posterView
                VStack(alignment: .leading, spacing: 5) {
                    headerView
                    Spacer()
                    Spacer()
                }
                .padding(16)

                Spacer()
            }
        }
        .lineLimit(1)
    }
}

struct ShowView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RepoView(repoItem: .repoItem)
                .frame(width: .infinity, height: 170.0, alignment: .center)
        }
    }
}
