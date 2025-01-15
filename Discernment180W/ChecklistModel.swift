//import SwiftUI
//import Foundation
//
//class ChecklistViewModel: ObservableObject {
//    @Published var checklist: [ChecklistItem] = [] {
//        didSet {
//            saveChecklist()
//        }
//    }
//
//    init() {
//        loadChecklist()
//    }
//
//    // Function to add a new checklist item
//    func addChecklistItem(text: String) {
//        let newItem = ChecklistItem(text: text)
//        checklist.append(newItem)
//    }
//
//    // Function to remove a checklist item by its index
//    func removeChecklistItem(at indexSet: IndexSet) {
//        checklist.remove(atOffsets: indexSet)
//    }
//
//    // Save checklist to UserDefaults
//    private func saveChecklist() {
//        do {
//            let data = try JSONEncoder().encode(checklist)
//            UserDefaults.standard.set(data, forKey: "ChecklistItems")
//        } catch {
//            print("Failed to save checklist: \(error)")
//        }
//    }
//
//    // Load checklist from UserDefaults
//    private func loadChecklist() {
//        if let data = UserDefaults.standard.data(forKey: "ChecklistItems") {
//            do {
//                checklist = try JSONDecoder().decode([ChecklistItem].self, from: data)
//            } catch {
//                print("Failed to load checklist: \(error)")
//            }
//        }
//    }
//}
