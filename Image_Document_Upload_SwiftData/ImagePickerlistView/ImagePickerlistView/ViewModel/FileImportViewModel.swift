//
//  FileImportViewModel.swift
//  ImagePickerlistView
//
//  Created by NishanthVibishKavi on 11/19/25.
//
import SwiftUI
import PhotosUI
import SwiftData

@Observable
class FileImportViewModel {
    var selectedPhoto: PhotosPickerItem?
    var selectedDocumentURL: URL?

    var showRenamePrompt = false
    var tempFileURL: URL?
    var tempFileName: String = ""

    func processPhotoSelection() async {
        guard let item = selectedPhoto else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                let ext = detectExtension(from: data)
                let tempURL = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension(ext)

                try data.write(to: tempURL)

                tempFileURL = tempURL
                tempFileName = "Image_\(Int(Date().timeIntervalSince1970)).\(ext)"
                showRenamePrompt = true
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }

    func processDocumentPicker(url: URL) {
        tempFileURL = url
        tempFileName = url.lastPathComponent
        showRenamePrompt = true
    }

    // MARK: Save to SwiftData
    func saveFile(modelContext: ModelContext) {
        guard let tempURL = tempFileURL else { return }

        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let saveURL = documentsDir.appendingPathComponent(tempFileName)

        if !FileManager.default.fileExists(atPath: saveURL.path) {
            try? FileManager.default.copyItem(at: tempURL, to: saveURL)
        }

        let item = LocalFileItem(fileName: tempFileName, fileURL: saveURL)
        modelContext.insert(item)

        tempFileURL = nil
    }

    private func detectExtension(from data: Data) -> String {
        if data.starts(with: [0xFF, 0xD8, 0xFF]) { return "jpg" }
        if data.starts(with: [0x89, 0x50, 0x4E, 0x47]) { return "png" }

        if let str = String(data: data.prefix(4), encoding: .ascii),
           str.starts(with: "GIF8") { return "gif" }

        if data.count > 12 {
            let header = String(data: data.prefix(32), encoding: .ascii) ?? ""
            if header.contains("ftyp") {
                if header.contains("heic") || header.contains("heix") ||
                    header.contains("hevc") || header.contains("heif") {
                    return "heic"
                }
            }
        }

        return "jpg"
    }
}
