//
//  StorageManager.swift
//  TaskList
//
//  Created by Илья Дубенский on 17.11.2022.
//
import CoreData

class StorageManager {

    static let shared = StorageManager()

    private init() {}

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func fetchData() -> [Task] {
        var tasks: [Task] = []
        let fetchRequest = Task.fetchRequest()

        do {
            tasks = try persistentContainer.viewContext.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }

        return tasks
    }

    // MARK: - CRUD
    func save(withTaskTitle title: String) -> Task? {
        guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return nil }
        let taskObject = Task(entity: entity, insertInto: persistentContainer.viewContext) 
        taskObject.title = title
        saveContext()
        return taskObject
    }

    func update(task: Task) {
        persistentContainer.viewContext.refresh(task, mergeChanges: true)
        saveContext()
    }

    func delete(task: Task) {
        persistentContainer.viewContext.delete(task)
        saveContext()
    }

}
