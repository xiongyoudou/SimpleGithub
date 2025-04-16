//
//  ContentView.swift
//  Shared
//
//  Created by xiong有都 on 2025/4/15.
//

import SwiftUI

public struct ErrorView: View {
    @EnvironmentObject var store: Store<AppState>
    var state: ErrorState? { store.state.screenState(for: .error) }

    public var body: some View {
        ZStack {
            
            
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ErrorView().environmentObject(store)
        }
    }
}
