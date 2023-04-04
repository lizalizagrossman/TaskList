//
//  ViewController.swift
//  TaskList
//
//  Created by Elizabeth on 03/04/2023.
//

import UIKit

enum AlertActionType {
    case saveAction
    case updateAction
}

class TaskListViewController: UITableViewController {
    
    private lazy var storageManager = StorageManager.shared
    
    private let cellID = "task"
    private var taskList: [Task] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchTasks()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID )
        setUpNavigationBar()
    }
    
    // MARK: - Private functions
    private func addNewTask(){
        showAlert(withTitle: "New Task", andMessage: "What do you want to do?", action: .saveAction)
    }
    
    private func showAlert(withTitle title: String, andMessage message: String, action: AlertActionType) {
        let indexPath = self.tableView.indexPathForSelectedRow ?? [0, 0]
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        switch action {
        case .saveAction:
            let saveAction = UIAlertAction(title: title, style: .default) { [weak self]_ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                    self?.save(task)
            }
            alert.addAction(saveAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
            }
        case .updateAction:
            let updateAction = UIAlertAction(title: title, style: .default) { [ weak self] _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                guard let taskChosen = self?.taskList[indexPath.row] else {return}
                self?.storageManager.updateTask(task: taskChosen, newTitle: task)
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            alert.addAction(updateAction)
            alert.addTextField { [ weak self ] textField in
                textField.text = self?.taskList[indexPath.row].title ?? "0"
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    private func save(_ taskName: String) {
        taskList.append(storageManager.createTask(taskName))
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }
    
    private func fetchTasks() {
        taskList = storageManager.fetchTasks()
    }
}

// MARK: - Setup UI
extension TaskListViewController {
    func setUpNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
            addNewTask()
            }
        )
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: UITableViewDataSource

extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = taskList[indexPath.row]
            taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            storageManager.deleteData(task)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showAlert(withTitle: "Update task",andMessage: "You can correct your task", action: .updateAction)
    }
}


