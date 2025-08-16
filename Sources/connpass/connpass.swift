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

// MARK: 共通リクエスト

extension Connpass {
    /// 内部用: 汎用的に API を呼び出し、指定型にデコード
    /// 外部から直接呼び出す必要はない
    /// - Parameters:
    ///   - endpoint: API エンドポイント
    ///   - queryStruct: クエリ構造体（任意）
    /// - Returns: 指定型にデコードされた結果
    private func request<T: Decodable>(
        endpoint: String,
        queryStruct: Any? = nil
    ) async throws -> T {
        let urlRequest = try ConnpassRequest.makeRequest(
            client: self, endpoint: endpoint, queryStruct: queryStruct)
        return try await ConnpassRequest.fetch(request: urlRequest, session: session, type: T.self)
    }
}
