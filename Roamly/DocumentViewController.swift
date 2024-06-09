//
//  DocumentViewController.swift
//  Roamly
//
//  Created by Justin Mai on 2/5/2024.
//

import UIKit
import UniformTypeIdentifiers
import QuickLookThumbnailing

class DocumentViewController: UIViewController, UIDocumentPickerDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    var files: [URL] = []
    var thumbnails: [URL: UIImage] = [:] // Dictionary to store thumbnails
    let CELL_DOC = "documentCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegate and data source for the table view
        tableView.delegate = self
        tableView.dataSource = self
        
        loadDocuments()
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        presentDocumentPicker()
    }
    
    func presentDocumentPicker() {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.pdf, UTType.plainText], asCopy: true)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            present(documentPicker, animated: true, completion: nil)
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            print("Document picked: \(url)")
            
            // Access file using NSFileCoordinator to handle file access safely
            let coordinator = NSFileCoordinator()
            var error: NSError?
            coordinator.coordinate(readingItemAt: url, options: [], error: &error) { (newURL) in
                self.addDocument(url: newURL)
            }
            
            if let error = error {
                print("Failed to access file with error: \(error.localizedDescription)")
                return
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // Handle the cancel action
            print("Document picker was cancelled")
        }
        
        func addDocument(url: URL) {
            // Copy the file to the app's documents directory
            do {
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                
                // Avoid overwriting existing files
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    let newName = UUID().uuidString + "_" + url.lastPathComponent
                    let uniqueURL = documentsURL.appendingPathComponent(newName)
                    try FileManager.default.copyItem(at: url, to: uniqueURL)
                    files.append(uniqueURL)
                    print("Files array: \(files)")
                } else {
                    try FileManager.default.copyItem(at: url, to: destinationURL)
                    files.append(destinationURL)
                    print("Files array: \(files)")
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                // Generate thumbnail for the document
                generateThumbnail(for: destinationURL)
                
            } catch {
                print("Error copying file: \(error.localizedDescription)")
            }
        }
        
        func generateThumbnail(for url: URL) {
            let size = CGSize(width: 100, height: 100)
            let scale = UIScreen.main.scale
            let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .thumbnail)
            
            QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { [weak self] (thumbnail, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Failed to generate thumbnail with error: \(error.localizedDescription)")
                    return
                }
                
                if let thumbnail = thumbnail {
                    // Store the generated thumbnail
                    self.thumbnails[url] = thumbnail.uiImage
                    print("Generated thumbnail: \(thumbnail.uiImage)")
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        func loadDocuments() {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
                files = fileURLs
                for fileURL in files {
                    generateThumbnail(for: fileURL)
                }
            } catch {
                print("Error loading documents: \(error.localizedDescription)")
            }
        }
        
        // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return files.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DOC, for: indexPath)
            let file = files[indexPath.row]
            cell.textLabel?.text = file.lastPathComponent
            
            // Show the thumbnail if available
            if let thumbnail = thumbnails[file] {
                cell.imageView?.image = thumbnail
            } else {
                cell.imageView?.image = UIImage(systemName: "doc")
            }
            
            return cell
        }
        
        // MARK: - UITableViewDelegate
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let file = files[indexPath.row]
            // Handle document selection, e.g., open the document or show details
            print("Selected file: \(file)")
        }
        
        // Add functionality to delete a document
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                let file = files.remove(at: indexPath.row)
                thumbnails[file] = nil // Remove the associated thumbnail
                try? FileManager.default.removeItem(at: file) // Delete the file
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
