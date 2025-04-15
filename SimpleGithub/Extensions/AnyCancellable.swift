//
//  AnyCancellable.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Combine
import Foundation

extension AnyCancellable {
    func store(in dictionary: inout [UUID: AnyCancellable], key: UUID) {
        dictionary[key] = self
    }
}
