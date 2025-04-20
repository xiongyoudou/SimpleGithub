//
//  ContentView.swift
//  Shared
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

public struct ErrorView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var store: Store<AppState>
        
    public var body: some View {
        Button("Go Back") {
            dismiss()
//            store.dispatch(ErrorStateAction.navigateBack)
        }
    }
}
