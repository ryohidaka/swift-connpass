//
//  EventRepository.swift
//  ConnpassDemo
//
//  Created by ryohidaka on 2025/08/17
//
//

import Foundation
import connpass

/// イベント取得用のリポジトリ
protocol EventRepositoryProtocol {
    func fetchEvents(keyword: String) async throws -> [Event]
}

/// Connpass API を利用した実装
final class EventRepository: EventRepositoryProtocol {
    private let client: Connpass

    /// APIキーは外部から注入
    init(apiKey: String) {
        self.client = Connpass(apiKey: apiKey)
    }

    /// キーワードでイベント検索
    func fetchEvents(keyword: String) async throws -> [Event] {
        if keyword.isEmpty {
            let response = try await client.getEvents()
            return response.events
        }

        let query = EventsQuery(keyword: [keyword])
        let response = try await client.getEvents(query: query)
        return response.events
    }
}
