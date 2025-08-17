//
//  ConnpassDemoApp.swift
//  ConnpassDemo
//
//  Created by ryohidaka on 2025/08/16
//
//

import SwiftUI

@main
struct ConnpassDemoApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // イベント一覧
                EventListView()
            }
        }
    }
}
