//
//  MaterialViewController.swift
//  Roamly
//
//  Created by Justin Mai on 8/6/2024.
//

import UIKit
import MobileCoreServices // Required for kUTType constants
import UniformTypeIdentifiers // For UTType

class MaterialViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up a button to trigger the import action
        let importButton = UIBarButtonItem(title: "Import CSV", style: .plain, target: self, action: #selector(importarCsv(sender:)))
        navigationItem.rightBarButtonItem = importButton
    }

    @objc func importarCsv(sender: UIBarButtonItem) {
        let types = [UTType.pdf.identifier, UTType.plainText.identifier]
        let importMenu = UIDocumentPickerViewController(documentTypes: types, in: .import)

        if #available(iOS 11.0, *) {
            importMenu.allowsMultipleSelection = false
        }
        
        importMenu.delegate = self
        present(importMenu, animated: true, completion: nil)
    }
}

// Extend MaterialViewController to conform to UIDocumentPickerDelegate
extension MaterialViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Note: The method signature has been updated to handle multiple URLs.
        print("urls : \(urls)")
        
        for url in urls {
            // Process each URL here
            // For example, you can read the file contents or move it to your app's directory
            do {
                let fileContent = try String(contentsOf: url)
                print("File Content: \(fileContent)")
            } catch {
                print("Error reading file at \(url): \(error)")
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
        controller.dismiss(animated: true, completion: nil)
    }
}

