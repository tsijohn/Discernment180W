import SwiftUI

class DailyChecklistViewModel: ObservableObject {
    @Published var checklistItems: [ChecklistItem] = [
        ChecklistItem(title: "Item 1", isCompleted: false),
        ChecklistItem(title: "Item 2", isCompleted: false),
        ChecklistItem(title: "Item 3", isCompleted: false),
        ChecklistItem(title: "Item 4", isCompleted: false)
    ]
    
    @Published var allCompleted: Bool = false

    func toggleCompletion(for index: Int) {
        checklistItems[index].isCompleted.toggle()
        updateAllCompletedState()
    }

    func setAllCompleted(_ completed: Bool) {
        for index in checklistItems.indices {
            checklistItems[index].isCompleted = completed
        }
        updateAllCompletedState()
    }

    private func updateAllCompletedState() {
        allCompleted = !checklistItems.contains { !$0.isCompleted }
    }

    struct ChecklistItem {
        var title: String
        var isCompleted: Bool
    }
}
