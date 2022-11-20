//
//  TaskListViewController.swift
//  TaskList
//
//  Created by Ilia D on 20.11.2022.
//

import UIKit


enum CellID: String {
    case task = "task"
}

class TaskListViewController: UITableViewController {

    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellID.task.rawValue)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskList = StorageManager.shared.fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(addNewTask)
            )
        ]
        
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showNewTaskAlert(withTitle: "New Task", andMessage: "What do you want to do?")
    }
}

// MARK: - UITableView Data Source
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellID.task.rawValue,
                                                 for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt  indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: "Delete") { [unowned self] (action, view, completionHandler) in
            self.deleteTask(forIndexPath: indexPath)
            completionHandler(true)
        }
        delete.backgroundColor = UIColor(named: "MilkRed")
        let configuration = UISwipeActionsConfiguration(actions: [delete])
        return configuration
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .destructive, title: "Edit") { [unowned self] (action, view, completionHandler) in
            let oldMessage = taskList[indexPath.row].title ?? ""
            self.showEditTaskAlert(withTitle: "Edit!", andMessage: "Your old task is - \"\(oldMessage)\" What do you want to do now?", with: indexPath)
            completionHandler(true)
        }
        edit.backgroundColor = UIColor(named: "MilkGreen")
        let configuration = UISwipeActionsConfiguration(actions: [edit])
        return configuration
    }
}

// MARK: - CRUD Methods
extension TaskListViewController {
    private func saveTask(withTaskTitle: String) {
        guard let newTask = StorageManager.shared.save(withTaskTitle: withTaskTitle) else { return }
        taskList.append(newTask)
        let indexPath = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .top)
    }

    private func deleteTask(forIndexPath indexPath: IndexPath) {
        StorageManager.shared.delete(task: taskList[indexPath.row])
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .right)
    }

    private func editTask(_ oldTask: Task, withNewTitle newTitle: String, forIndexPath indexPath: IndexPath) {
        oldTask.title = newTitle
        StorageManager.shared.update(task: oldTask)
        tableView.reloadRows(at: [indexPath], with: .left)
    }
}

// MARK: - Alerts
extension TaskListViewController {
    private func showNewTaskAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let saveAction = UIAlertAction(title: "Save",style: .default) { [unowned self] _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.saveTask(withTaskTitle: task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }

    private func showEditTaskAlert(withTitle title: String, andMessage message: String, with indexPath: IndexPath, with placeholder: String? = "Edit Task") {
        let task = taskList[indexPath.row]
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] _ in
            guard let editedTask = alert.textFields?.first?.text, !editedTask.isEmpty else { return }
            self.editTask(task, withNewTitle: editedTask, forIndexPath: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = placeholder
        }
        present(alert, animated: true)
    }
}


