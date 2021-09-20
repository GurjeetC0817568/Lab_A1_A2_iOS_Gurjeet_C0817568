//
//  ProductTableViewController.swift
//  Lab_A1_A2_iOS_Gurjeet_C0817568
//
//  Created by Gurjeet KJ on 19/09/21.
//  Copyright © 2021 Gurjeet KJ. All rights reserved.
//


import UIKit
import CoreData

class ProductTableViewController: UITableViewController {
    
    // MARK: -  global constants and variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // context for core data
    let searchController = UISearchController(searchResultsController: nil) // define search controller
    var products = [Product]() // create products array to show table
    var providers = [Provider]() // create providers array to show table
    var selectedProduct: Product? = nil // selected product global variable
    var selectedProvider: Provider? = nil // selected provider global variable
    var selectMode = false // selectmode global variable
    
    var isProductSelection = true // product/provider selection global variable
    
    // MARK: -  view functions
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProviders()// load providers from coredata
        loadProducts()// load product from coredata
        if(products.count == 0){
        loadDemoDataIfEmpty() //initially when no data entered then demo default data added
        }
        //print(products)
        showSearchBar() // shows and set searchbar
    }
    override func viewDidAppear(_ animated: Bool) {
        loadProviders()// loads providers  from core data
        loadProducts()// loads products from core data
    }
    
    
    // MARK: - Action functions
    @IBAction func listEditClick(_ sender: Any) {
        selectMode = !selectMode // toggle selectmode
        tableView.setEditing(selectMode, animated: true)
    }
    
   
    @IBAction func changeMode(_ sender: UIBarButtonItem) {
        if isProductSelection {
                   navigationItem.title = "Providers" // top title as Providers
                   sender.title = "Show Products" // bottom button to show products
               }else{
                   navigationItem.title = "Products" // top title as Products
                   sender.title = "Show Providers"  // bottom button to show providers
               }
               isProductSelection = !isProductSelection // toggle product/provider mode
               tableView.reloadData() // reload tableview
    }
    
    
    // MARK: - Table view functions
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            if isProductSelection{
            return products.count // get the total products
            }else{
                return providers.count // get the total providers
            }
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "product_segue", for: indexPath)
           if isProductSelection {
               cell.textLabel?.text = products[indexPath.row].name! // set title as product name
             cell.detailTextLabel?.text = String((products[indexPath.row].parentProvider?.name)! )// set detail as provider name

               cell.imageView!.image = nil
           }else{
               cell.textLabel?.text = providers[indexPath.row].name! // set title as provider name
            cell.detailTextLabel?.text = String(providers[indexPath.row].products!.count)// set detail as provider count of products
               cell.imageView!.image = UIImage(systemName: "folder.fill")
           }
           
           if indexPath.row % 2 != 0{ // even odd coloring
               cell.backgroundColor = .systemBlue // background blue
               cell.textLabel?.textColor = .white //  text white
               cell.detailTextLabel?.textColor = .white // detail label text white
               cell.imageView!.tintColor =  .white
           }else{
               cell.backgroundColor = .white // background blue
               cell.textLabel?.textColor = .systemBlue  // text blue
               cell.detailTextLabel?.textColor = .systemBlue  // detail label text blue
               cell.imageView!.tintColor =  .systemBlue
           }
           return cell
       }
       

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { // if editing style is delete
            if isProductSelection { // if product selection true
                deleteProduct(product: products[indexPath.row]) // deletes the product selected
                products.remove(at: indexPath.row) // removes the product from the global list
               for (provider) in providers{ // iterates all the providers
                if provider.products?.count == 0 { // validates if has no products
                        deleteProvider(provider: provider) // deletes the provider
                    }
                }
             }else{
                 deleteProvider(provider: providers[indexPath.row]) // deletes the provider
                 providers.remove(at: indexPath.row) // removes the provider from the global list
             }
            // Delete the row from the datasource
            tableView.deleteRows(at: [indexPath], with: .fade) // remove rows from the list
            loadProviders()// loads provider from core data
            loadProducts()// loads products from core data
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !selectMode { // if not in select mode
            if(isProductSelection){ // if in product selection is true
                selectedProduct = products[indexPath.row] // select product
                performSegue(withIdentifier: "toEditProduct", sender: self) // edit product segue
            }else{
                selectedProvider = providers[indexPath.row] // select provider
                performSegue(withIdentifier: "toProviderProducts", sender: self) // providers product segue
            }
        }
    }
    
    
    // MARK: - Aux functions
    func getProviderByName(ProviderNameForSearch:String) -> Provider?{
        for provider in providers{
            if provider.name == ProviderNameForSearch{ // if provider equal searche name
                return provider // returns provider object if matches
            }
        }
        return nil // returns nil
    }
   
    
    // MARK: - Load Demo data initially
    func loadDemoDataIfEmpty(){
           //if data is null initially then adding some demo content: 3 products
              let prov1 = Provider(context: context)
              prov1.name = "Apple" //Initial 1 demo provider
          
                   do {
                       try context.save()
                      }
                catch {
                      print("Error loading notes \(error.localizedDescription)") // print error if any
                      }
        
            //adding 3 demo product at first in core data if empty
            let prod1 = Product(context: context)
            prod1.name = "Macbook PRO"
            prod1.id = "MP123"
            prod1.p_description="Macbook pro 16 inch has 3.3GB sequential read speeds, Intel Core i7 or i9 processor,2TB SSd storage, 20 hours of battery life, 16‑core Neural Engine."
            prod1.price=1000.00
            prod1.parentProvider = prov1
           
           let prod2 = Product(context: context)
           prod2.name = "Macbook Air M1"
           prod2.id = "MA786"
           prod2.p_description="M1 has the fastest 8-Core CPU,2TB SSd storage, M1 Apple chip, 8 hours of battery life, 16‑core Neural Engine."
           prod2.price=1299.00
           prod2.parentProvider = prov1
           
           let prod3 = Product(context: context)
           prod3.name = "iPad PRO"
           prod3.id = "IPD333"
           prod3.p_description="M1 performance, 8‑core GPU, a breathtaking XDR display and fast wireless. Buckle up."
           prod3.price=810.00
           prod3.parentProvider = prov1
                  
                      do {
                          try context.save()
                          //print("products saved initially")
                      }
                      catch {
                          print("Error loading notes \(error.localizedDescription)")
                      }
                  
       }

    
    // MARK: - Load functions
    // load products from coredata
    func loadProducts(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Product> = Product.fetchRequest() // get the request object
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // sort the request by name
        if (predicate != nil) { // in case there is a predicate
            request.predicate = predicate // set it to the request
        }
        do {
            products = try context.fetch(request) // fetch context and asign to products variable
            //print(products)
        } catch {
            print("Error loading products \(error.localizedDescription)") // print error if any
        }
        tableView.reloadData() // reloads the table data
    }
    
    //load providers from coredata
    func loadProviders(predicate: NSPredicate? = nil) {
        let request: NSFetchRequest<Provider> = Provider.fetchRequest() // get the request object
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)] // sort the request by name
        if (predicate != nil) { // in case there is a predicate
            request.predicate = predicate // set it to the request
        }
        do {
            providers = try context.fetch(request) // fetch context and asign to providers variable
        } catch {
            print("Error loading products \(error.localizedDescription)") // print error if any
        }
        tableView.reloadData() // reload table data
    }
    
    
    //MARK: - deleting functions
    func deleteProduct(product: Product){
        context.delete(product) // delete product
        do {
            try context.save() // save context
        } catch {
            print("Error saving the product \(error.localizedDescription)")  // print error if any
        }
    }
    func deleteProvider(provider: Provider){
        context.delete(provider) // delete the provider
        do {
            try context.save() // saves the context
        } catch {
            print("Error saving the product \(error.localizedDescription)")  // print error if any
        }
    }
    //MARK: - segue functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ProductViewController  { // if the destination is the product view controller
            destination.delegate = self// Get new view controller using segue.destination and validates if Product
            if segue.identifier == "toEditProduct" { // if the segue is edit product
                destination.selectedProduct = selectedProduct  // Pass selected product to new view controller
            }
        }
        
        if let destination = segue.destination as? ProviderProductsTableViewController  { // when destination is providerProductsTableViewController
            destination.selectedProvider = selectedProvider // set the selected provider
        }
    }
    
    @IBAction func unwindToProductViewController(_ unwindSegue: UIStoryboardSegue) { // when modal product dismissed
        loadProviders()// load provider from coredata
        loadProducts()// load products from coredata
    }
    
    
    //MARK: - search bar functiion
    func showSearchBar() {
        searchController.searchBar.delegate = self // sets the delegate
        searchController.obscuresBackgroundDuringPresentation = false // set false obscure background during presentation
        if isProductSelection {//if products selection
            searchController.searchBar.placeholder = "Search Product" // set searchbar placeholder
        }else{
            searchController.searchBar.placeholder = "Search Provider" // set searchbar placeholder
        }
        navigationItem.searchController = searchController // set searchbar controller
        definesPresentationContext = true // set presentation context
        searchController.searchBar.searchTextField.textColor = .lightGray // set search bar text color
    }
}

//MARK: - search bar delegate methods
extension ProductTableViewController: UISearchBarDelegate {
    // when the search button is clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text?.count == 0 { // if the search bar is empty
            loadProducts() // load all the products
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }else{
            // add predicate if name & description contains searchbar text
           
            if isProductSelection{ // if product selection true
                // search by product name or description if contains searchbar text
                let predicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K CONTAINS[cd] %@", argumentArray:["name", searchBar.text!, "p_description", searchBar.text!] )
                loadProducts(predicate: predicate)  // load products from core data
            }else{
                // search by provider name if contains searchbar text
                let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", argumentArray:["name", searchBar.text!] )
                loadProviders(predicate: predicate)  // load providers from core data
            }
                
        }
    }
    // when the cancel button is pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = "" // erase the search bar content
        if isProductSelection{ // if product selection true
            loadProducts() // load the products from coredata
        }else{
            loadProviders()   // load providers from coredata
        }
    }
    
}
