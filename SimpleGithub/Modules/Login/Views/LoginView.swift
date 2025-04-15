//
//  HomeView.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack {
            Button(action: {
                print("click me")
            }) {
                NavigationLink(destination: HomeView()) {
                    Text("Login")
                        .padding()
                        .font(.headline)
                        .foregroundColor(.red)
                        .background(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}
