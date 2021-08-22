
import CryptoKit
import SwiftUI
import Foundation
#if os(macOS)
import AppKit
#else
import UIKit
#endif

public struct WidgetImage<Placehold: View>: View {
    
    let url: String
    
    @ViewBuilder var placehold: Placehold
    
    let fileManager: FileManager = .default
    
    public var body: some View {
        if let data = try? data(with: url) {
            image(with: data)
        }else if let data = try? dataFromRemote(with: url) {
            image(with: data)
        }else {
            placehold
        }
    }
    
    private func image(with data: Data) -> Image {
        #if os(macOS)
        return Image(nsImage: NSImage(data: data)).resizable()
        #else
        return Image(uiImage: UIImage(data: data) ?? UIImage()).resizable()
        #endif
    }
    
    private func store(data: Data, with url: String) throws {
        let path = try cachePath(with: url)
        try data.write(to: path)
    }
    
    private func data(with url: String) throws -> Data? {
        let path = try cachePath(with: url)
        if fileManager.fileExists(atPath: path.absoluteString) {
            return try Data(contentsOf: path)
        }else {
            return nil
        }
    }
    
    private func dataFromRemote(with url: String) throws -> Data {
        let path = try cachePath(with: url)
        let data = try Data(contentsOf: path)
        try store(data: data, with: url)
        return data
    }
    
    private func cachePath(with url: String) throws -> URL {
        let key = url.md5String
        return try fileManager.url(for: .cachesDirectory, in: .allDomainsMask, appropriateFor: nil, create: false).appendingPathComponent("widgetImageCache").appendingPathComponent(key, isDirectory: false)
    }
}

extension String {
    var md5String: String {
        let digest = Insecure.MD5.hash(data: self.data(using: .utf8) ?? Data())
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}
