import SwiftUI
import WebKit

@main
struct DSMLivePhotoApp: App {
    var body: some Scene {
        WindowGroup {
            WebView()
                .ignoresSafeArea()
                .background(Color(red: 0.027, green: 0.039, blue: 0.102))
        }
    }
}

struct WebView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        cfg.userContentController.add(context.coordinator, name: "save")
        let wv = WKWebView(frame: .zero, configuration: cfg)
        wv.scrollView.bounces = false
        wv.scrollView.contentInsetAdjustmentBehavior = .never
        wv.isOpaque = false
        wv.backgroundColor = .clear
        if let url = Bundle.main.url(forResource: "index", withExtension: "html") {
            wv.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKScriptMessageHandler {
        func userContentController(_ c: WKUserContentController, didReceive m: WKScriptMessage) {
            guard let d = m.body as? [String: Any],
                  let name = d["name"] as? String,
                  let b64 = d["data"] as? String,
                  let data = Data(base64Encoded: b64) else { return }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
            try? data.write(to: url)
            DispatchQueue.main.async {
                let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                let root = UIApplication.shared.connectedScenes
                    .compactMap { ($0 as? UIWindowScene)?.keyWindow }.first?.rootViewController
                vc.popoverPresentationController?.sourceView = root?.view
                root?.present(vc, animated: true)
            }
        }
    }
}
