//
//  EventListViewModel.swift
//  ConnpassDemo
//
//  Created by ryohidaka on 2025/08/17
//
//

import SwiftUI
import connpass

@MainActor
final class EventListViewModel: ObservableObject {
    @Published var keyword: String = ""
    @Published var events: [Event] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String?

    private var repository: EventRepositoryProtocol?

    init() {
        do {
            // Keychain から APIキーを取得
            let apiKeyStore = APIKeyStore()
            let apiKey = try apiKeyStore.fetch()
            self.repository = EventRepository(apiKey: apiKey)
        } catch {
            self.errorMessage = "APIキーの取得に失敗しました"
            self.showError = true
            print("APIKeyStore fetch error:", error)
        }
    }

    /// イベントを取得（キーワードなしでも検索可能）
    func fetchEvents() async {
        guard let repository = repository else {
            events = []
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // キーワードが空なら nil を渡して全件取得
            let searchKeyword: String? = keyword.isEmpty ? nil : keyword
            let fetchedEvents = try await repository.fetchEvents(
                keyword: searchKeyword ?? "Mobile"
            )
            self.events = fetchedEvents
        } catch {
            self.errorMessage = "イベント取得に失敗しました"
            self.showError = true
            print("Event fetch error:", error)
            self.events = []
        }
    }
}
