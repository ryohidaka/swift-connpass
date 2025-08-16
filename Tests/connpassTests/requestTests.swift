//
//  requestTests.swift
//  connpassTests
//
//  Created by ryohidaka on 2025/08/16
//

import Foundation
import Testing

@testable import connpass

// Actor を使ってモックデータを安全に保持
actor MockDataStore {
    static let shared = MockDataStore()
    private var data: Data?

    // データをセットする
    func setData(_ newData: Data?) {
        data = newData
    }

    // データを取得する
    func getData() -> Data? {
        data
    }

    // 同期的にデータを取得するテスト用メソッド
    nonisolated func unsafeData() -> Data? {
        // await を使わず同期的に取得
        let semaphore = DispatchSemaphore(value: 0)
        var result: Data?
        Task {
            result = await self.getData()
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
}

// MARK: - encodeQuery テスト

struct connpassRequestTests {

    @Test("クエリ構造体を正しく URLQueryItem に変換できること")
    func testEncodeQuery() async throws {
        struct QueryStruct {
            let keyword: String
            let count: Int
            let tags: [String]
        }

        let query = QueryStruct(keyword: "swift", count: 10, tags: ["ios", "api"])
        let items = ConnpassRequest.encodeQuery(from: query)

        #expect(items.contains(where: { $0.name == "keyword" && $0.value == "swift" }))
        #expect(items.contains(where: { $0.name == "count" && $0.value == "10" }))

        let tagValues = items.filter { $0.name == "tags" }.compactMap { $0.value }
        #expect(tagValues.contains("ios"))
        #expect(tagValues.contains("api"))
    }

    // MARK: - makeRequest テスト

    @Test("URLRequest が正しく作成できること")
    func testMakeRequest() async throws {
        let client = Connpass(apiKey: "test_api_key")
        struct QueryStruct {
            let q: String
        }
        let query = QueryStruct(q: "test")

        let request = try ConnpassRequest.makeRequest(
            client: client, endpoint: "events", queryStruct: query)

        #expect(request.url?.absoluteString.contains("events") == true)
        #expect(request.url?.query?.contains("q=test") == true)
        #expect(request.value(forHTTPHeaderField: "X-API-Key") == "test_api_key")
        #expect(request.httpMethod == "GET")
    }

    // MARK: - fetch テスト

    @Test("fetch がデコードを正しく行うこと")
    func testFetch() async throws {
        // モック JSON データと URLSession を用意
        struct MockResponse: Decodable, Equatable {
            let name: String
        }

        let mockData = """
            { "name": "testEvent" }
            """.data(using: .utf8)!

        // モック URLProtocol
        class MockURLProtocol: URLProtocol {

            // すべてのリクエストに対応
            override class func canInit(with request: URLRequest) -> Bool { true }

            // リクエストの正規化（そのまま返す）
            override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

            // 非 async に変更し、同期的にデータを返す
            override func startLoading() {
                // Actor から同期的にデータ取得
                let data = MockDataStore.shared.unsafeData() ?? Data()

                // データをクライアントに渡す
                self.client?.urlProtocol(self, didLoad: data)

                // HTTPレスポンスを返す
                let response = HTTPURLResponse(
                    url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                self.client?.urlProtocol(
                    self, didReceive: response, cacheStoragePolicy: .notAllowed)

                // ローディング完了を通知
                self.client?.urlProtocolDidFinishLoading(self)
            }

            override func stopLoading() {}
        }

        // データを actor にセット
        await MockDataStore.shared.setData(mockData)

        // モックセッション作成
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)

        // テスト用リクエスト
        let request = URLRequest(url: URL(string: "https://example.com")!)

        // fetch を実行してデコードを確認
        let result = try await ConnpassRequest.fetch(
            request: request, session: session, type: MockResponse.self)
        #expect(result == MockResponse(name: "testEvent"))
    }

}
