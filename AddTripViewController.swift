//
//  AddTripViewController.swift
//  Roamly
//
//  Created by Justin Mai on 3/8/2024.
//

import Foundation
import FirebaseFirestore

protocol AddTripDelegate: AnyObject {
    func didAddTrip(_ trip: Trip)
}

class AddTripViewController: UIViewController, UITextFieldDelegate {
    
 
    @IBOutlet weak var submitTripButton: UIButton!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var tripName: UITextField!
    
    weak var delegate: AddTripDelegate?
    
    
       
       override func viewDidLoad() {
           super.viewDidLoad()

           
           // Set up text fields
           if let tripName = tripName {
                   tripName.delegate = self
               } else {
                   print("tripName is nil")
               }
           // Set up date pickers
           startDatePicker.datePickerMode = .date
           startDatePicker.preferredDatePickerStyle = .wheels
           
           endDatePicker.datePickerMode = .date
           endDatePicker.preferredDatePickerStyle = .wheels
           
           // Set up the submit button action
           submitTripButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
       }
       
       private func saveTripToFirestore(name: String, startDate: Date, endDate: Date) {
           let db = Firestore.firestore()
           let tripsCollection = db.collection("trips")
           
           let tripData: [String: Any] = [
               "tripName": name,
               "startDate": Timestamp(date: startDate),
               "endDate": Timestamp(date: endDate)
           ]
           
           tripsCollection.addDocument(data: tripData) { error in
               if let error = error {
                   print("Error adding document: \(error)")
                   self.showAlert(message: "Failed to save trip. Please try again.")
               } else {
                   print("Document added successfully.")
                   self.showAlert(message: "Trip added.")
                   self.clearForm()
                   
                   // Notify the delegate
                   let trip = Trip(tripName: name, startDate: startDate, endDate: endDate)
                   self.delegate?.didAddTrip(trip)
               }
           }
       }
       
       @objc func submitButtonTapped() {
           guard let name = tripName.text, !name.isEmpty else {
               showAlert(message: "Please enter a valid trip name.")
               return
           }
           
           let startDate = startDatePicker.date
           let endDate = endDatePicker.date
           
           guard startDate <= endDate else {
               showAlert(message: "End date must be after the start date.")
               return
           }
           
           // Process the trip data
           print("Trip Name: \(name)")
           print("Trip Start Date: \(startDate)")
           print("Trip End Date: \(endDate)")
           
           // Save the trip data to Firestore
           saveTripToFirestore(name: name, startDate: startDate, endDate: endDate)
       }
       
       private func showAlert(message: String) {
           let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
               // Perform any action after the alert is dismissed, such as navigating back
               self.navigationController?.popViewController(animated: true)
           }))
           present(alert, animated: true, completion: nil)
       }
       
       private func clearForm() {
           tripName.text = ""
           startDatePicker.setDate(Date(), animated: false)
           endDatePicker.setDate(Date(), animated: false)
       }
       
       // MARK: - UITextFieldDelegate
       
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
}
