//
//  connpass.swift
//  connpass
//
//  Created by ryohidaka on 2025/08/16
//
//

import Foundation

// MARK: - APIクライアント

/// Connpass APIクライアント
///
/// 例:
/// ```swift
/// // デフォルト設定でクライアントを生成
/// let client1 = Connpass(apiKey: "<YOUR_API_KEY>")
///
/// // カスタム設定でクライアントを生成
/// let config = URLSessionConfiguration.ephemeral
/// let client2 = Connpass(apiKey: "<YOUR_API_KEY>", configuration: config)
/// ```
public class Connpass {
    public let apiKey: String
    public let baseURL: URL
    public let session: URLSession

    /// 指定された API キーで Connpass クライアントを生成する
    /// - Parameters:
    ///   - apiKey: Connpass API Key
    ///   - configuration: URLSession の設定（省略時はデフォルト設定を使用）
    public init(apiKey: String, configuration: URLSessionConfiguration? = nil) {
        self.apiKey = apiKey
        self.baseURL = URL(string: ConnpassConstants.baseURL)!
        self.session = URLSession(configuration: configuration ?? .default)
    }
}
