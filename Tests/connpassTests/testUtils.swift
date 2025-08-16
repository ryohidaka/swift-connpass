//
//  TestUtils.swift
//  connpassTests
//

import Foundation

@testable import connpass

final class TestUtils {

    // MARK: - Fixture 読み込み

    /// 指定した JSON ファイルを Data として読み込む
    /// - Parameter name: Fixture ファイル名（拡張子なし）
    /// - Returns: Data
    /// - Throws: ファイルが存在しない場合や読み込み失敗時にエラー
    static func loadFixtureData(_ name: String) throws -> Data {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw NSError(
                domain: "TestUtils",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Fixture \(name) が見つかりません"]
            )
        }
        return try Data(contentsOf: url)
    }

    // MARK: - URLSession モック

    /// モック HTTP 用の URLSession を生成する
    /// - Parameters:
    ///   - data: レスポンスとして返す Data
    ///   - statusCode: HTTP ステータスコード
    /// - Returns: モック用 URLSession
    static func makeMockSession(data: Data?, statusCode: Int = 200) -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]

        // セッションごとにユニークキーを生成してモックデータを登録
        let key = UUID().uuidString
        URLProtocolMock.setMockData(for: key, data: data, statusCode: statusCode)
        config.httpAdditionalHeaders = ["URLProtocolMockKey": key]

        return URLSession(configuration: config)
    }

    // MARK: - 異常系レスポンス確認

    /// 異常系ステータスコードで API を呼び出す
    /// - Parameters:
    ///   - connpass: Connpass クライアント
    ///   - statusCode: モックで返す HTTP ステータスコード
    /// - Returns: 発生したエラー（正常時は nil）
    static func testHTTPError(connpass: Connpass, statusCode: Int) async -> Error? {
        let dummyData = try? JSONSerialization.data(withJSONObject: [:])
        connpass.session.configuration.protocolClasses = [URLProtocolMock.self]

        let key = UUID().uuidString
        URLProtocolMock.setMockData(for: key, data: dummyData, statusCode: statusCode)
        connpass.session.configuration.httpAdditionalHeaders = ["URLProtocolMockKey": key]

        let query = EventsQuery(keyword: ["BPStudy"])
        do {
            _ = try await connpass.getEvents(query: query)
            return nil
        } catch {
            return error
        }
    }

    // MARK: - URLProtocolMock

    /// URLSession モック用のカスタム URLProtocol
    final class URLProtocolMock: URLProtocol {

        /// 並列安全なモックデータストア
        private final class MockStore {
            nonisolated(unsafe) static let shared = MockStore()
            private var map = [String: (Data?, Int)]()
            private let queue = DispatchQueue(label: "URLProtocolMock.MockStoreQueue")

            /// モックデータを登録
            func setMockData(for key: String, data: Data?, statusCode: Int) {
                queue.sync { map[key] = (data, statusCode) }
            }

            /// モックデータを取得
            func getMockData(for key: String) -> (Data?, Int) {
                queue.sync { map[key] ?? (nil, 200) }
            }
        }

        // MARK: - 公開メソッド

        /// セッションごとにモックデータを登録
        static func setMockData(for key: String, data: Data?, statusCode: Int) {
            MockStore.shared.setMockData(for: key, data: data, statusCode: statusCode)
        }

        // MARK: - URLProtocol Overrides

        override class func canInit(with request: URLRequest) -> Bool { true }
        override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

        override func startLoading() {
            guard let client = client,
                let key = request.allHTTPHeaderFields?["URLProtocolMockKey"]
            else { return }

            let (data, statusCode) = MockStore.shared.getMockData(for: key)

            if let data {
                let response = HTTPURLResponse(
                    url: request.url!,
                    statusCode: statusCode,
                    httpVersion: nil,
                    headerFields: nil
                )!
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client.urlProtocol(self, didLoad: data)
            }
            client.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {}
    }
}
