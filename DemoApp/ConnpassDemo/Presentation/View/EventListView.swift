//
//  EventListView.swift
//  ConnpassDemo
//
//  Created by ryohidaka on 2025/08/17
//
//

import SwiftUI

/// イベント一覧表示
struct EventListView: View {
    @StateObject private var viewModel = EventListViewModel()
    @State private var isFirstAppear = true  // 初回表示判定用

    var body: some View {
        NavigationStack {
            ZStack {
                VStack {
                    // キーワード検索用のテキストフィールドと検索ボタン
                    HStack {
                        TextField("キーワードで検索", text: $viewModel.keyword)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.search)
                            .onSubmit {
                                Task {
                                    await viewModel.fetchEvents()
                                }
                            }

                        Button(action: {
                            Task {
                                await viewModel.fetchEvents()
                            }
                        }) {
                            Text("検索")
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding()

                    // イベント一覧表示
                    List(viewModel.events, id: \.id) { event in
                        NavigationLink(
                            destination: EventDetailView(event: event)
                        ) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.headline)
                                Text(event.catchMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Text(event.startedAt.ISO8601Format())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }

                // ローディング表示（上に重なる）
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView("読み込み中...")
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10).fill(Color.white)
                        )
                        .shadow(radius: 10)
                }
            }
            .navigationTitle("イベント一覧")
            // エラー表示
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("エラー"),
                    message: Text(viewModel.errorMessage ?? "不明なエラー"),
                    dismissButton: .default(Text("OK"))
                )
            }
            // 初回表示時のみ検索
            .onAppear {
                if isFirstAppear {
                    isFirstAppear = false
                    Task {
                        await viewModel.fetchEvents()
                    }
                }
            }
        }
    }
}
