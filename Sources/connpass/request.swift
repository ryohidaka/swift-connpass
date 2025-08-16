//
//  request.swift
//  connpass
//
//  Created by ryohidaka on 2025/08/16
//
//

import Foundation

public struct ConnpassRequest {

    // MARK: - クエリ構造体の URLQueryItem 変換

    /// 任意の struct を URLQueryItem の配列に変換する
    ///
    /// 配列の場合は同じキーで複数の値を作成する
    /// - Parameter queryStruct: エンコード対象の struct
    /// - Returns: URLQueryItem の配列
    public static func encodeQuery(from queryStruct: Any) -> [URLQueryItem] {
        let mirror = Mirror(reflecting: queryStruct)
        var queryItems: [URLQueryItem] = []

        for child in mirror.children {
            guard let key = child.label else { continue }
            let value = child.value

            // 配列の場合は複数 queryItem を生成
            if let array = value as? [CustomStringConvertible], !array.isEmpty {
                for v in array { queryItems.append(URLQueryItem(name: key, value: v.description)) }
            } else if let v = value as? CustomStringConvertible {
                queryItems.append(URLQueryItem(name: key, value: v.description))
            }
        }
        return queryItems
    }

    // MARK: - URLRequest の生成

    /// URL とクエリ構造体から URLRequest を生成する
    ///
    /// - Parameters:
    ///   - client: Connpass クライアント
    ///   - endpoint: API エンドポイント
    ///   - queryStruct: 任意のクエリ構造体
    /// - Returns: URLRequest
    /// - Throws: URL生成失敗時にエラーを投げる
    public static func makeRequest(
        client: Connpass,
        endpoint: String,
        queryStruct: Any? = nil
    ) throws -> URLRequest {

        var components = URLComponents(
            url: client.baseURL.appendingPathComponent(endpoint),
            resolvingAgainstBaseURL: false)!

        if let queryStruct = queryStruct {
            let items = encodeQuery(from: queryStruct)
            if !items.isEmpty { components.queryItems = items }
        }

        guard let url = components.url else {
            throw NSError(
                domain: "ConnpassRequest", code: 1,
                userInfo: [NSLocalizedDescriptionKey: "URLの生成に失敗しました"])
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(client.apiKey, forHTTPHeaderField: ConnpassConstants.apiKeyHeaderField)
        return request
    }

    // MARK: - データ取得 & デコード

    /// URLRequest を使って API からデータを取得し、指定型にデコードする
    ///
    /// - Parameters:
    ///   - request: URLRequest
    ///   - session: URLSession
    ///   - type: デコード先の型
    /// - Returns: 指定型にデコードされた値
    /// - Throws: ネットワークエラー、HTTPステータスエラー、JSONデコードエラー
    public static func fetch<T: Decodable>(
        request: URLRequest,
        session: URLSession,
        type: T.Type
    ) async throws -> T {

        // データ取得
        let (data, response) = try await session.data(for: request)

        // HTTP ステータスチェック
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(
                domain: "ConnpassRequest", code: 2,
                userInfo: [NSLocalizedDescriptionKey: "HTTPレスポンスが不正です"])
        }

        switch httpResponse.statusCode {
        case 200..<400: break
        case 400..<500:
            throw NSError(
                domain: "ConnpassRequest", code: httpResponse.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "クライアントエラー: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                ])
        case 500..<600:
            throw NSError(
                domain: "ConnpassRequest", code: httpResponse.statusCode,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "サーバーエラー: \(HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode))"
                ])
        default:
            throw NSError(
                domain: "ConnpassRequest", code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "予期せぬステータス: \(httpResponse.statusCode)"])
        }

        // JSONデコード
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NSError(
                domain: "ConnpassRequest", code: 3,
                userInfo: [NSLocalizedDescriptionKey: "JSONデコードに失敗: \(error.localizedDescription)"])
        }
    }
}
