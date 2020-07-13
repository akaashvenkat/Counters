//
//  MasterViewController.swift
//  Counter
//
//  Created by Akaash Venkat on 7/7/20.
//  Copyright © 2020 Akaash Venkat. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	var detailViewController: DetailViewController? = nil
	var managedObjectContext: NSManagedObjectContext? = nil


	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		navigationItem.leftBarButtonItem = editButtonItem

		if #available(iOS 13.0, *) {
			if self.traitCollection.userInterfaceStyle == .dark {
				self.tableView.backgroundColor = UIColor.black
			} else {
				self.tableView.backgroundColor = UIColor.white
			}
		}
		
		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
		navigationItem.rightBarButtonItem = addButton
		if let split = splitViewController {
		    let controllers = split.viewControllers
		    detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
		super.viewWillAppear(animated)
	}

	@objc
	func insertNewObject(_ sender: Any) {
		displayForm(message: "")
	}
	
	func displayForm(message: String) {
		
		var counter_title: UITextField!
		var counter_val: UITextField!
		
		let alert = UIAlertController(title: "New Counter", message: message, preferredStyle: .alert)
		
		alert.addTextField(configurationHandler: {(textField: UITextField!) in
			textField.placeholder = "Counter Title..."
			textField.autocapitalizationType = UITextAutocapitalizationType.words
			counter_title = textField
		})
		
		alert.addTextField(configurationHandler: {(textField: UITextField!) in
			textField.placeholder = "Counter Value..."
			textField.keyboardType = UIKeyboardType.numberPad
			counter_val = textField
		})
		
		self.present(alert, animated: true, completion: nil)
		
		let cancelAction = UIAlertAction(title: "Cancel" , style: .default)
		let saveAction = UIAlertAction(title: "Add", style: .default) { (action) -> Void in
			
			if((counter_title.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
				|| (counter_val.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! ){
				
				counter_title.text = ""
				counter_val.text = ""
				
				self.displayForm(message: "One of the values entered was invalid. Please re-enter information.")
			}
			else {
				let context = self.fetchedResultsController.managedObjectContext
				let newEvent = Event(context: context)
				
				// If appropriate, configure the new managed object.
				newEvent.timestamp = Date()
				newEvent.counterTitle = counter_title.text!
				newEvent.counterVal = Int64(counter_val.text!)!
				
				// Save the context.
				do {
					try context.save()
				} catch {
					let nserror = error as NSError
					fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
				}
			}
		}
		alert.addAction(cancelAction)
		alert.addAction(saveAction)
		
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = tableView.indexPathForSelectedRow {
		    let object = fetchedResultsController.object(at: indexPath)
		        let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
		        controller.detailItem = object
		        controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
		        controller.navigationItem.leftItemsSupplementBackButton = true
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController.sections?.count ?? 0
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let sectionInfo = fetchedResultsController.sections![section]
		return sectionInfo.numberOfObjects
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
		if #available(iOS 13.0, *) {
			if self.traitCollection.userInterfaceStyle == .dark {
				cell.contentView.backgroundColor = UIColor.black
				cell.textLabel?.textColor = UIColor.white
				cell.detailTextLabel?.textColor = UIColor.systemGreen
			} else {
				cell.contentView.backgroundColor = UIColor.white
				cell.textLabel?.textColor = UIColor.black
				cell.detailTextLabel?.textColor = UIColor.blue
			}
		}
		cell.accessoryType = .disclosureIndicator
		
		let event = fetchedResultsController.object(at: indexPath)
		configureCell(cell, withEvent: event)
		return cell
	}

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
		    let context = fetchedResultsController.managedObjectContext
		    context.delete(fetchedResultsController.object(at: indexPath))
		        
		    do {
		        try context.save()
		    } catch {
		        // Replace this implementation with code to handle the error appropriately.
		        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
		        let nserror = error as NSError
		        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
		    }
		}
	}

	func configureCell(_ cell: UITableViewCell, withEvent event: Event) {
		cell.textLabel!.text = event.counterTitle
		cell.detailTextLabel!.text = "Count: " + String(event.counterVal)
	}

	// MARK: - Fetched results controller

	var fetchedResultsController: NSFetchedResultsController<Event> {
	    if _fetchedResultsController != nil {
	        return _fetchedResultsController!
	    }
	    
	    let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
	    
	    // Set the batch size to a suitable number.
	    fetchRequest.fetchBatchSize = 20
	    
	    // Edit the sort key as appropriate.
		let sortDescriptor = NSSortDescriptor(key: "counterTitle", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
	    
	    fetchRequest.sortDescriptors = [sortDescriptor]
	    
	    // Edit the section name key path and cache name if appropriate.
	    // nil for section name key path means "no sections".
	    let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Counters")
	    aFetchedResultsController.delegate = self
	    _fetchedResultsController = aFetchedResultsController
	    
	    do {
	        try _fetchedResultsController!.performFetch()
	    } catch {
	         // Replace this implementation with code to handle the error appropriately.
	         // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	         let nserror = error as NSError
	         fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
	    }
	    
	    return _fetchedResultsController!
	}    
	var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

	func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	    tableView.beginUpdates()
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
	    switch type {
	        case .insert:
	            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
	        case .delete:
				tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
	        default:
	            return
	    }
	}

	func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
	    switch type {
	        case .insert:
	            tableView.insertRows(at: [newIndexPath!], with: .fade)
	        case .delete:
	            tableView.deleteRows(at: [indexPath!], with: .fade)
	        case .update:
				configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
	        case .move:
	            configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
	            tableView.moveRow(at: indexPath!, to: newIndexPath!)
			default:
				return
	    }
	}

	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
	    tableView.endUpdates()
	}

}

