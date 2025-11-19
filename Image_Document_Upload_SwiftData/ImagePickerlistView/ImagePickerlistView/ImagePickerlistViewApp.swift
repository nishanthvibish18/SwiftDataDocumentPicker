//
//  ImagePickerlistViewApp.swift
//  ImagePickerlistView
//
//  Created by NishanthVibishKavi on 11/19/25.
//

import SwiftUI
import SwiftData

@main
struct ImagePickerlistViewApp: App {
    var body: some Scene {
        WindowGroup {
            DocumentManagerView()

        }
        .modelContainer(for: LocalFileItem.self)

    }
}
