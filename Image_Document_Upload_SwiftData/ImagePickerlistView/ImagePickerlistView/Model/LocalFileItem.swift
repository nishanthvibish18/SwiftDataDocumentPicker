//
//  LocalFileItem.swift
//  ImagePickerlistView
//
//  Created by NishanthVibishKavi on 11/19/25.
//

import SwiftData
import Foundation

@Model
class LocalFileItem {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var fileURL: URL
    var createdAt: Date

    init(fileName: String, fileURL: URL) {
        self.id = UUID()
        self.fileName = fileName
        self.fileURL = fileURL
        self.createdAt = Date()
    }
}
