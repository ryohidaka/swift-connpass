//
//  connpassTests.swift
//  connpassTests
//
//  Created by ryohidaka on 2025/08/16
//
//

import Foundation
import Testing

@testable import connpass

// MARK: - クライアント初期化

struct connpassTests {

    @Test("クライアントを初期化できること（デフォルト設定）")
    func testDefaultInitialization() async throws {
        let apiKey = "test_api_key"
        let client = Connpass(apiKey: apiKey)

        #expect(client.apiKey == apiKey)
        #expect(client.baseURL.absoluteString == ConnpassConstants.baseURL)
        #expect(
            client.session.configuration.identifier == URLSessionConfiguration.default.identifier)
    }

    @Test("クライアントを初期化できること（カスタム設定）")
    func testCustomConfigurationInitialization() async throws {
        let apiKey = "test_api_key"
        let config = URLSessionConfiguration.ephemeral
        let client = Connpass(apiKey: apiKey, configuration: config)

        #expect(client.apiKey == apiKey)
        #expect(client.baseURL.absoluteString == ConnpassConstants.baseURL)
        #expect(client.session.configuration.identifier == config.identifier)
    }
}
