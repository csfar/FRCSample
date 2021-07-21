//
//  ViewController.swift
//  SampleSxasdas
//
//  Created by Artur Carneiro on 21/07/21.
//

import UIKit
import CoreData

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    private let coreData = CoreDataStack.shared

    private lazy var frc: NSFetchedResultsController<Entry> = {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Entry.createdAt, ascending: false)]

        let frc = NSFetchedResultsController<Entry>(fetchRequest: fetchRequest,
                                                    managedObjectContext: coreData.mainContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        frc.delegate = self

        return frc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CellFRC")
        tableView.delegate = self
        tableView.dataSource = self

        do {
            try frc.performFetch()
        } catch {
            print("Não foi")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.fetchedObjects?.count ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellFRC") else {
            fatalError("Could not dequeue cell with given identifier")
        }

        let object = frc.object(at: indexPath)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd:HH:ss"

        guard let date = object.createdAt else {
            cell.textLabel?.text = "UNDEFINED"
            return cell
        }

        cell.textLabel?.text = dateFormatter.string(from: date)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj = frc.object(at: indexPath)
        coreData.mainContext.delete(obj)
    }

    @IBAction func didTapAdd(_ sender: UIBarButtonItem) {
        _ = Entry(context: coreData.mainContext)

        do {
            try coreData.save()
        } catch let error as CoreDataStackError {
            switch error {
            case .contextHasNoChanges:
                print("No change in context")
            case .failedToSave:
                print("Failed to save context")
            }
        } catch {
            print("Unknown error")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension Entry {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        self.createdAt = Date()
    }
}

