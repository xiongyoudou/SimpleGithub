//
//  Store.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation
import Combine
import SwiftUI

/// Namespace for Middlewares
enum Middlewares {}
protocol Action {}
struct NoOpAction: Action {}

typealias Reducer<State> = (State, Action) -> State
typealias Middleware<State> = (State, Action) -> AnyPublisher<Action, Never>

final class Store<State>: ObservableObject {
    var isEnabled = true

    @Published private(set) var state: State

    private var subscriptions: [UUID: AnyCancellable] = [:]

    private let queue = DispatchQueue(label: "pl.wojciechkulik.SimpleGithub.store", qos: .userInitiated)
    private let reducer: Reducer<State>
    private let middlewares: [Middleware<State>]

    init(
        initial state: State,
        reducer: @escaping Reducer<State>,
        middlewares: [Middleware<State>]
    ) {
        self.state = state
        self.reducer = reducer
        self.middlewares = middlewares
    }

    func restoreState(_ state: State) {
        self.state = state
    }

    func dispatch(_ action: Action) {
        guard isEnabled else { return }

        queue.sync {
            self.dispatch(self.state, action)
        }
    }

    private func dispatch(_ currentState: State, _ action: Action) {
        let newState = reducer(currentState, action)

        middlewares.forEach { middleware in
            let key = UUID()
            middleware(newState, action)
                .receive(on: RunLoop.main)
                .handleEvents(receiveCompletion: { [weak self] _ in self?.subscriptions.removeValue(forKey: key) })
                .sink(receiveValue: dispatch)
                .store(in: &subscriptions, key: key)
        }

        withAnimation {
            state = newState
        }
    }
}
