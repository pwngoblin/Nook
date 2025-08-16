//
//  WebsiteView.swift
//  Pulse
//
//  Created by Maciek Bagiński on 28/07/2025.
//

import SwiftUI
import WebKit

struct WebsiteView: View {
    @EnvironmentObject var browserManager: BrowserManager
    let tab = Tab(id: UUID(), url: URL(string: "umszki.hu")!, name: "dd", favicon: "", spaceId: UUID(), index: 0)
    var body: some View {
        Group {
            if let currentTab = browserManager.tabManager.currentTab {
                HStack {
                    TabWebViewWrapper(tab: currentTab)
                        .id(currentTab.id)
                        .background(Color(nsColor: .windowBackgroundColor))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: {
                            if #available(macOS 26.0, *) {
                                return 12
                            } else {
                                return 6
                            }
                        }()))
                    if let split = currentTab.split {
                        /*
                        TabWebViewWrapper(tab: tab)
                            .id(tab.id)
                            .background(Color(nsColor: .windowBackgroundColor))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: {
                                if #available(macOS 26.0, *) {
                                    return 12
                                } else {
                                    return 6
                                }
                            }()))*/
                        Text("c")
                    }
                }
            } else {
                EmptyWebsiteView()
            }
        }
    }
}

// MARK: - Tab WebView Wrapper
struct TabWebViewWrapper: NSViewRepresentable {
    let tab: Tab

    func makeNSView(context: Context) -> WKWebView {
        let webView = tab.webView
        print("Showing WebView for tab: \(tab.name)")
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // The webView is managed by the Tab
    }
}
