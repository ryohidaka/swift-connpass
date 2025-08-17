# swift-connpass

Swift用connpass API v2クライアント

## インストール

Swift Package Manager を使用して追加できます:

```swift
dependencies: [
    .package(url: "https://github.com/ryohidaka/swift-connpass.git", from: "0.1.0")
]
```

## 使用例

> [!IMPORTANT]
> すべての API エンドポイントでは、API キーによる認証が必須です。
>
> API キーの発行には[ヘルプページ](https://help.connpass.com/api/)での利用申請が必要です。

### クライアント生成

```swift
import connpass

// デフォルト設定でクライアントを生成
let client = Connpass(apiKey: "<YOUR_API_KEY>")

// カスタム設定でクライアントを生成
let config = URLSessionConfiguration.ephemeral
let client2 = Connpass(apiKey: "<YOUR_API_KEY>", configuration: config)
```

### イベント一覧取得

```swift
let events = try await client.getEvents()
print(events)
```

## リンク

- [API リファレンス](https://connpass.com/about/api/v2/)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
