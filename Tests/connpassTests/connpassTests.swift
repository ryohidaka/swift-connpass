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

// MARK: - イベント一覧取得

extension connpassTests {

    @Test("イベント一覧を取得できること")
    func testGetEventsSuccess() async throws {
        // Arrange
        let data = try TestUtils.loadFixtureData("events")
        let session = TestUtils.makeMockSession(data: data, statusCode: 200)

        let connpass = Connpass(apiKey: "dummy-key", configuration: session.configuration)
        let query = EventsQuery(keyword: ["BPStudy"])

        // Act
        let response = try await connpass.getEvents(query: query)

        // Assert
        #expect(response.resultsReturned == 1)
        #expect(response.resultsAvailable == 1)
        #expect(response.resultsStart == 1)
        #expect(response.events.count == 1)

        guard let event = response.events.first else {
            Issue.record("イベント情報がnilです。")
            return
        }

        // イベント基本情報
        #expect(event.id == 364)
        #expect(event.title == "BPStudy#56")
        #expect(event.catchMessage == "株式会社ビープラウドが主催するWeb系技術討論の会")
        #expect(event.description.contains("BPStudy#56はオープンクラウドキャンパスさん"))  // 長文なので部分一致で検証
        #expect(event.url == "https://bpstudy.connpass.com/event/364/")
        #expect(
            event.imageUrl
                == "https://media.connpass.com/thumbs/f4/e1/f4e196d7a73922d5e570fba9193ed9e4.png")
        #expect(event.hashTag == "bpstudy")

        // 日付類
        let formatter = ISO8601DateFormatter()
        #expect(event.startedAt == formatter.date(from: "2012-04-17T18:30:00+09:00"))
        #expect(event.endedAt == formatter.date(from: "2012-04-17T20:30:00+09:00"))
        #expect(event.updatedAt == formatter.date(from: "2014-06-30T10:06:19+09:00"))

        // イベント属性
        #expect(event.limit == nil)
        #expect(event.eventType.rawValue == "participation")
        #expect(event.openStatus.rawValue == "close")

        // グループ情報
        #expect(event.group?.id == 1)
        #expect(event.group?.title == "BPStudy")
        #expect(event.group?.url == "https://bpstudy.connpass.com/")

        // 開催場所
        #expect(event.address == "東京都港区北青山2-8-44")
        #expect(event.place == "先端技術館＠TEPIA")
        #expect(event.lat == 35.672968000000)
        #expect(event.lon == 139.716904600000)

        // 管理者情報
        #expect(event.ownerId == 8)
        #expect(event.ownerNickname == "haru860")
        #expect(event.ownerDisplayName == "佐藤 治夫")

        // 参加人数
        #expect(event.accepted == 0)
        #expect(event.waiting == 0)

        // シリーズ（nullなので nil チェック）
        #expect(event.series == nil)
    }

    @Test("イベント一覧取得時にHTTPエラーが発生すること")
    func testGetEventsError() async {
        // Arrange
        let data = try? TestUtils.loadFixtureData("events")
        let session = TestUtils.makeMockSession(data: data, statusCode: 404)

        let connpass = Connpass(apiKey: "dummy-key", configuration: session.configuration)
        let query = EventsQuery(keyword: ["BPStudy"])

        // Act
        var caughtError: Error?
        do {
            _ = try await connpass.getEvents(query: query)
        } catch {
            caughtError = error
        }

        // Assert
        #expect(caughtError != nil)
        if let nsError = caughtError as NSError? {
            #expect(nsError.domain == "ConnpassRequest")
            #expect(nsError.code == 404)
            #expect(nsError.localizedDescription.contains("クライアントエラー"))
        }
    }
}
