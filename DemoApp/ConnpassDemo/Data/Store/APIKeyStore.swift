//
//  APIKeyStore.swift
//  ConnpassDemo
//
//  Created by ryohidaka on 2025/08/17
//
//

import Foundation

/// Secrets.plist から APIキーを取得するクラス
final class APIKeyStore {
    /// plist から APIキーを取得
    func fetch() throws -> String {
        guard
            let url = Bundle.main.url(
                forResource: "Secrets",
                withExtension: "plist"
            ),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(
                from: data,
                format: nil
            ) as? [String: Any],
            let apiKey = plist["CONNPASS_API_KEY"] as? String,
            !apiKey.isEmpty
        else {
            throw NSError(
                domain: "APIKeyStore",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "APIキーが見つかりません"]
            )
        }
        return apiKey
    }
}
