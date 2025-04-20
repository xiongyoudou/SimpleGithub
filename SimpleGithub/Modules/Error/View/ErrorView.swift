//
//  ContentView.swift
//  Shared
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

struct ErrorView: View {
    @Environment(\.dismiss) var dismiss
    
    let title: String
    let message: String
    let dismissAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
                .padding(.top, 40)
            
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: {
                    dismiss()
                }) {
                    Text("返回")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(20)
    }
}
