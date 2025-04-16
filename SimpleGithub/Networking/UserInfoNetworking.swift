//
//  UsersRepository.swift
//  SimpleGithub
//
//  Created by Wojciech Kulik on 29/11/2021.
//

import Foundation
import Combine

enum UserInfoNetworkingError: Error {
    case unknown
    case couldNotFind
}

final class UserInfoNetworking: ObservableObject {
    public func requestUserInfo(accessToken: String, completion: @escaping (Result<GitHubUser, Error>) -> Void){
        let userURL = URL(string: "https://api.github.com/user")!
        var request = URLRequest(url: userURL)
        request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let user = try JSONDecoder().decode(GitHubUser.self, from: data)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                    print("Error decoding user: \(error)")
                }
            }
        }.resume()
    }
}
