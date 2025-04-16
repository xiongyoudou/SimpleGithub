//
//  GithubRepos.swift
//  SimpleGithub
//
//  Created by xiong有都 on 2025/4/15.
//

import Foundation
import Combine
import UIKit

//enum GithubReposNetworkingError: Error {
//    case unknown
//    case couldNotFind
//}
//
//
//final class GithubReposNetworking: ObservableObject {
//    private let simulatedDelay: RunLoop.SchedulerTimeType.Stride = 1.0
//
//    func fetchReposWithKeyword(phrase: String? = nil) -> AnyPublisher<[GitHubRepo], GithubReposNetworkingError> {
//        let isFiltering = phrase != nil
//        let phrase = phrase?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//        let repos = [GitHubRepo.repoItem, GitHubRepo.repoItem2]
//            .filter { phrase == "" || $0.name.lowercased().contains(phrase) }
//
//        return Just(repos)
//            .delay(for: isFiltering ? 0.0 : simulatedDelay, scheduler: RunLoop.main)
//            .setFailureType(to: GithubReposNetworkingError.self)
//            .eraseToAnyPublisher()
//    }
//}


class GitHubAuthManager: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var accessToken: String?
    @Published var error: Error?
    
    private let clientId = "Ov23liqyqQFEmgz34qeb"
    private let clientSecret = "6f5bc736acc7b1c8b5a77523402bad7086916c66"
    private let callbackScheme = "simplegithub"
    
    private let baseURL = "https://api.github.com"
    
    func startGitHubLogin() {
        let scope = "user" // 需要的权限范围
        let authURL = URL(string: "https://github.com/login/oauth/authorize?client_id=\(clientId)&scope=\(scope)&redirect_uri=\(callbackScheme)://github-auth")!
        
        UIApplication.shared.open(authURL)
    }
    
    func handleCallback(url: URL) {
        guard url.scheme == callbackScheme else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let code = components?.queryItems?.first(where: { $0.name == "code" })?.value else {
            self.error = AuthError.missingCode
            return
        }
        
        exchangeCodeForToken(code: code)
    }
    
    private func exchangeCodeForToken(code: String) {
        let tokenURL = URL(string: "https://github.com/login/oauth/access_token")!
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let params = [
            "client_id": clientId,
            "client_secret": clientSecret,
            "code": code,
            "redirect_uri": "\(callbackScheme)://github-auth"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    self.error = AuthError.noData
                }
                return
            }
            
            do {
                let response = try JSONDecoder().decode(GitHubTokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self.accessToken = response.access_token
                    self.isAuthenticated = true
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = error
                }
            }
        }.resume()
    }
    
    func fetchReposWithKeyword(accessToken: String, phrase: String? = nil) -> AnyPublisher<[GitHubRepo], GitHubError> {
        guard let url = URL(string: "\(baseURL)/user/repos") else {
            return Fail(error: GitHubError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("token \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw GitHubError.noData
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    if httpResponse.statusCode == 401 {
                        throw GitHubError.unauthorized
                    } else {
                        throw GitHubError.apiError("HTTP Error: \(httpResponse.statusCode)")
                    }
                }
                return data
            }
            .decode(type: [GitHubRepo].self, decoder: JSONDecoder())
            .mapError { error -> GitHubError in
                if let githubError = error as? GitHubError {
                    return githubError
                } else if let decodingError = error as? DecodingError {
                    return .decodingError
                } else {
                    return .apiError(error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }
}

struct GitHubTokenResponse: Codable {
    let access_token: String
    let token_type: String
    let scope: String
}

enum AuthError: Error {
    case missingCode
    case noData
}


