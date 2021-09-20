//
//  ProviderProductsTableViewController.swift
//  Lab_A1_A2_iOS_Gurjeet_C0817568
//
//  Created by Gurjeet KJ on 20/09/21.
//  Copyright © 2021 Gurjeet KJ. All rights reserved.
//

import UIKit
import CoreData

class ProviderProductsTableViewController: UITableViewController {

    var providerProducts = [Product]() // list of provider products
       let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
       
       var selectedProvider: Provider? {
           didSet {
               loadProds()
           }
       }
       override func viewDidLoad() {
           super.viewDidLoad()
           navigationItem.title = selectedProvider?.name // provider name in view title
       }
       
       func loadProds() {
           let request: NSFetchRequest<Product> = Product.fetchRequest()  // get request object
           
           // searching  products with selected provider using predicate
           let providerPredicate = NSPredicate(format: "parentProvider.name=%@", selectedProvider!.name!)
           request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // sort by name
           request.predicate = providerPredicate // setting predicate
           
           do {
               providerProducts = try context.fetch(request) // assign context to provider products
           } catch {
               print("Error loading notes \(error.localizedDescription)") // print error if any
           }
           tableView.reloadData() // reloads the table data
       }
       
       // MARK: - Table view data source
       
       override func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }
       
       
       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return providerProducts.count
       }
       
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "provider_segue", for: indexPath)
           cell.textLabel?.text = providerProducts[indexPath.row].name! // title as product name
           
           return cell
       }

       
       
   }

