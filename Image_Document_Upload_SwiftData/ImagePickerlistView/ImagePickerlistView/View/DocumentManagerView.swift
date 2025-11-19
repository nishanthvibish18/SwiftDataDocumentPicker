//
//  DocumentManagerView.swift
//  ImagePickerlistView
//
//  Created by NishanthVibishKavi on 11/19/25.
//

import SwiftUI
import PhotosUI
import QuickLook
import SwiftData

struct DocumentManagerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LocalFileItem.createdAt, order: .reverse) var items: [LocalFileItem]

    @State private var vm = FileImportViewModel()

    @State private var showPhotoPicker = false
    @State private var showDocumentPicker = false

    @State private var previewURL: URL?

    var body: some View {
        NavigationStack {
            List {
                ForEach(items) { item in
                    Button {
                        previewURL = item.fileURL
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                            VStack(alignment: .leading) {
                                Text(item.fileName)
                                Text(item.createdAt.formatted())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("My Files")

            .overlay(alignment: .bottomTrailing) {
                floatingButton
            }

            .quickLookPreview($previewURL)

            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $vm.selectedPhoto,
                matching: .images
            )
            .onChange(of: vm.selectedPhoto) { _, _ in
                Task { await vm.processPhotoSelection() }
            }

            .sheet(isPresented: $showDocumentPicker) {
                DocumentPickerView { url in
                    vm.processDocumentPicker(url: url)
                }
            }

            .alert("Rename File", isPresented: $vm.showRenamePrompt) {
                TextField("File name", text: $vm.tempFileName)
                Button("Save") { vm.saveFile(modelContext: modelContext) }
                Button("Cancel", role: .cancel) { }
            }
        }
    }

//MARK: Floating Button View
    private var floatingButton: some View {
        Menu {
            Button("Upload Image") { showPhotoPicker = true }
            Button("Upload Document") { showDocumentPicker = true }
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
                .padding()
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        offsets.forEach { index in
            modelContext.delete(items[index])
        }
    }
}
