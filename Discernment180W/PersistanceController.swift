import CoreData
import SwiftUI

// PersistenceController class to manage Core Data stack and data fetching
class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    // Initialize Core Data stack
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Discernment180")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    // Preview setup for Core Data
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<3 {
            let newReading = Reading(context: viewContext)
            newReading.dayNumber = Int16(i)
            newReading.content = "Day \(i + 1) content goes here."
        }
        try? viewContext.save()
        return result
    }()
}

