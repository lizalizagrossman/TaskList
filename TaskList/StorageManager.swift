//
//  StorageManager.swift
//  TaskList
//
//  Created by Elizabeth on 03/04/2023.
//

import Foundation
import CoreData

class StorageManager {
    static let shared = StorageManager()
    private let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "TaskList")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    func createTask(_ taskTitle: String) -> Task {
        let context = persistentContainer.viewContext
        let task = Task(context: context)
        task.title = taskTitle
        saveContext()
        return task
    }
    
    func updateTask(task: Task, newTitle: String? ) {
        if let newTitle = newTitle {
            task.title = newTitle
        }
    }
    
    func fetchTasks() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        let context = persistentContainer.viewContext
        do {
            let tasks = try context.fetch(fetchRequest)
            return tasks
        } catch {
            fatalError("Failed to fetch tasks: \(error.localizedDescription)")
        }
    }
    
    func deleteData(_ entity: Task) {
        let context = persistentContainer.viewContext
        print(entity)
        context.delete(entity)
        saveContext()
    }
    
}
