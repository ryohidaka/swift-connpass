//
//  Event.swift
//  connpass
//
//  Created by ryohidaka on 2025/08/16
//
//

import Foundation

// MARK: クエリ

/// イベント検索クエリ
public struct EventsQuery: Encodable {
    /// 検索の開始位置（1以上、デフォルト:1）
    public var start: Int?

    /// 取得件数（1〜100、デフォルト:10）
    public var count: Int?

    /// イベントID（複数指定可）
    public var eventID: [Int]?

    /// キーワード(AND)（複数指定可）
    public var keyword: [String]?

    /// キーワード(OR)（複数指定可）
    public var keywordOr: [String]?

    /// イベント開催年月（例: 201204）
    public var ym: [String]?

    /// イベント開催年月日（例: 20120406）
    public var ymd: [String]?

    /// 参加者のニックネーム
    public var nickname: [String]?

    /// 管理者のニックネーム
    public var ownerNickname: [String]?

    /// グループID
    public var groupID: [Int]?

    /// サブドメイン
    public var subdomain: [String]?

    /// 都道府県
    public var prefecture: [Prefecture]?

    /// 表示順（1: 更新日時順, 2: 開催日時順, 3: 新着順）
    public var order: EventOrder?

    public init(
        start: Int? = nil,
        count: Int? = nil,
        eventID: [Int]? = nil,
        keyword: [String]? = nil,
        keywordOr: [String]? = nil,
        ym: [String]? = nil,
        ymd: [String]? = nil,
        nickname: [String]? = nil,
        ownerNickname: [String]? = nil,
        groupID: [Int]? = nil,
        subdomain: [String]? = nil,
        prefecture: [Prefecture]? = nil,
        order: EventOrder? = nil
    ) {
        self.start = start
        self.count = count
        self.eventID = eventID
        self.keyword = keyword
        self.keywordOr = keywordOr
        self.ym = ym
        self.ymd = ymd
        self.nickname = nickname
        self.ownerNickname = ownerNickname
        self.groupID = groupID
        self.subdomain = subdomain
        self.prefecture = prefecture
        self.order = order
    }
}

/// 表示順
public enum EventOrder: Int, Encodable {
    case updatedAt = 1
    case startedAt = 2
    case createdAt = 3
}

// MARK: レスポンス

/// イベント一覧のレスポンス
public struct EventsResponse: Codable, Sendable {
    /// 含まれる検索結果の件数
    public let resultsReturned: Int

    /// 検索結果の総件数
    public let resultsStart: Int

    /// 検索結果の開始位置
    public let resultsAvailable: Int

    /// イベント一覧
    public let events: [Event]

    enum CodingKeys: String, CodingKey {
        case resultsReturned = "results_returned"
        case resultsStart = "results_start"
        case resultsAvailable = "results_available"
        case events
    }
}

// MARK: イベント

/// イベント
public struct Event: Codable, Sendable {
    /// イベントID
    public let id: Int

    /// イベント名
    public let title: String

    /// キャッチコピー
    public let catchMessage: String

    /// イベント概要
    public let description: String

    /// Connpass上のイベントURL
    public let url: String

    /// イベント画像URL
    public let imageUrl: String

    /// X(Twitter)のハッシュタグ
    public let hashTag: String

    /// 開始日時
    public let startedAt: Date

    /// 終了日時
    public let endedAt: Date

    /// 定員
    public let limit: Int?

    /// イベント参加タイプ
    public let eventType: EventType

    /// イベントの開催状態
    public let openStatus: OpenStatus

    /// グループ情報
    public let group: Group?

    /// 開催場所
    public let address: String

    /// 開催会場
    public let place: String

    /// 緯度
    public let lat: Double?

    /// 経度
    public let lon: Double?

    /// 管理者ID
    public let ownerId: Int

    /// 管理者ニックネーム
    public let ownerNickname: String

    /// 管理者表示名
    public let ownerDisplayName: String

    /// 参加者数
    public let accepted: Int?

    /// 補欠者数
    public let waiting: Int?

    /// 更新日時
    public let updatedAt: Date

    /// シリーズ情報
    public let series: Series?

    /// シリーズ情報
    public struct Series: Codable, Sendable {
        /// シリーズID
        public let id: Int

        /// シリーズタイトル
        public let title: String

        /// シリーズURL
        public let url: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case catchMessage = "catch"
        case description
        case url
        case imageUrl = "image_url"
        case hashTag = "hash_tag"
        case startedAt = "started_at"
        case endedAt = "ended_at"
        case limit
        case eventType = "event_type"
        case openStatus = "open_status"
        case group
        case address
        case place
        case lat
        case lon
        case ownerId = "owner_id"
        case ownerNickname = "owner_nickname"
        case ownerDisplayName = "owner_display_name"
        case accepted
        case waiting
        case updatedAt = "updated_at"
        case series
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        catchMessage = try container.decode(String.self, forKey: .catchMessage)
        description = try container.decode(String.self, forKey: .description)
        url = try container.decode(String.self, forKey: .url)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        hashTag = try container.decode(String.self, forKey: .hashTag)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        endedAt = try container.decode(Date.self, forKey: .endedAt)
        limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        eventType = try container.decode(EventType.self, forKey: .eventType)
        openStatus = try container.decode(OpenStatus.self, forKey: .openStatus)
        group = try container.decodeIfPresent(Group.self, forKey: .group)
        address = try container.decode(String.self, forKey: .address)
        place = try container.decode(String.self, forKey: .place)

        if let latString = try? container.decode(String.self, forKey: .lat) {
            lat = Double(latString)
        } else {
            lat = try container.decodeIfPresent(Double.self, forKey: .lat)
        }

        if let lonString = try? container.decode(String.self, forKey: .lon) {
            lon = Double(lonString)
        } else {
            lon = try container.decodeIfPresent(Double.self, forKey: .lon)
        }

        ownerId = try container.decode(Int.self, forKey: .ownerId)
        ownerNickname = try container.decode(String.self, forKey: .ownerNickname)
        ownerDisplayName = try container.decode(String.self, forKey: .ownerDisplayName)
        accepted = try container.decodeIfPresent(Int.self, forKey: .accepted)
        waiting = try container.decodeIfPresent(Int.self, forKey: .waiting)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        series = try container.decodeIfPresent(Series.self, forKey: .series)
    }
}

/// イベント参加タイプ
public enum EventType: String, Codable, Sendable {
    case participation
    case advertisement
}

/// イベントの開催状態
public enum OpenStatus: String, Codable, Sendable {
    case preOpen = "preopen"
    case open = "open"
    case close = "close"
    case cancelled = "cancelled"
}

/// グループ
public struct Group: Codable, Sendable {
    public let id: Int
    public let subdomain: String
    public let title: String
    public let url: String
}
