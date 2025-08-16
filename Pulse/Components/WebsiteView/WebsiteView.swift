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
                    // PRIMARY
                    TabWebViewWrapper(
                        tab: currentTab,
                        onFocused: { browserManager.focusedSplit = .primary },
                    )
                    .id(currentTab.id)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay( // optional visual cue
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(browserManager.focusedSplit == .primary ? .blue.opacity(0.4) : .clear, lineWidth: 2)
                    )
                    
                    if currentTab.split != nil {
                        // SECONDARY
                        TabWebViewWrapper(
                            tab: tab,
                            onFocused: { browserManager.focusedSplit = .secondary },
                            onBlurred: { }
                        )
                        .id(tab.id)
                        .background(Color(nsColor: .windowBackgroundColor))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(browserManager.focusedSplit == .secondary ? .blue.opacity(0.4) : .clear, lineWidth: 2)
                        )
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
    var onFocused: (() -> Void)? = nil
    var onBlurred: (() -> Void)? = nil
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeNSView(context: Context) -> WKWebView {
        let webView = tab.webView
        context.coordinator.webView = webView
        
        // Click -> becomes active split immediately
        let click = NSClickGestureRecognizer(target: context.coordinator,
                                             action: #selector(Coordinator.clicked))
        webView.addGestureRecognizer(click)
        
        // Re-evaluate focus on common transitions
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.windowKeyChanged),
            name: NSWindow.didBecomeKeyNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.windowKeyChanged),
            name: NSWindow.didResignKeyNotification, object: nil
        )
        
        // Keep in sync on keystrokes/mouse downs
        context.coordinator.monitor = NSEvent.addLocalMonitorForEvents(
            matching: [.keyDown, .leftMouseDown]
        ) { [weak webView] ev in
            context.coordinator.evaluateFocus(for: webView)
            return ev
        }
        
        return webView
    }
    
    func updateNSView(_ nsView: WKWebView, context: Context) {}
    
    class Coordinator: NSObject {
        var parent: TabWebViewWrapper
        weak var webView: WKWebView?
        var monitor: Any?
        
        init(_ parent: TabWebViewWrapper) { self.parent = parent }
        
        deinit {
            if let monitor { NSEvent.removeMonitor(monitor) }
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func clicked() { evaluateFocus(for: webView, forceFocus: true) }
        
        @objc func windowKeyChanged() { evaluateFocus(for: webView) }
        
        func evaluateFocus(for view: WKWebView?, forceFocus: Bool = false) {
            guard let view else { return }
            let isFocused = forceFocus || view.containsFirstResponder(in: view.window)
            isFocused ? parent.onFocused?() : parent.onBlurred?()
        }
    }
}
private extension NSView {
    func containsFirstResponder(in window: NSWindow?) -> Bool {
        guard let fr = window?.firstResponder as? NSView else { return false }
        return fr === self || fr.isDescendant(of: self)
    }
}
