//
//  EventDetailView.swift
//  ConnpassDemo
//
//  Created by ryohidaka on 2025/08/17
//
//

import SwiftUI
import connpass

/// イベント詳細表示
struct EventDetailView: View {
    let event: Event

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // サムネイル表示
                if !event.imageUrl.isEmpty,
                    let url = URL(string: event.imageUrl)
                {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(8)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // タイトル
                Text(event.title)
                    .font(.title)
                    .bold()

                // キャッチコピー
                Text(event.catchMessage)
                    .font(.body)

                // 日時
                Text("開始日時: \(event.startedAt.ISO8601Format())")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // HStack で項目名と内容
                VStack(alignment: .leading, spacing: 8) {
                    if !event.address.isEmpty {
                        HStack(alignment: .top) {
                            Text("開催場所:")
                                .bold()
                            Text(event.address)
                        }
                    }

                    if !event.place.isEmpty {
                        HStack(alignment: .top) {
                            Text("会場:")
                                .bold()
                            Text(event.place)
                        }
                    }

                    if !event.hashTag.isEmpty {
                        HStack(alignment: .top) {
                            Text("ハッシュタグ:")
                                .bold()
                            Text("#\(event.hashTag)")
                        }
                    }

                    HStack(alignment: .top) {
                        Text("主催グループ:")
                            .bold()
                        Text(event.group?.title ?? "")
                    }

                    HStack(alignment: .top) {
                        Text("主催者:")
                            .bold()
                        Text(event.ownerDisplayName)
                    }

                    HStack(alignment: .top) {
                        Text("イベントURL:")
                            .bold()
                        if let url = URL(string: event.url) {
                            Link("詳細はこちら", destination: url)
                        }
                    }
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("イベント詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}
