//
//  ProductViewController.swift
//  Lab_A1_A2_iOS_Gurjeet_C0817568
//
//  Created by Gurjeet KJ on 19/09/21.
//  Copyright © 2021 Gurjeet KJ. All rights reserved.
//

import UIKit
import CoreData

class ProductViewController: UIViewController {
    
    var selectedProduct: Product? = nil // the selected product for edit process
    weak var delegate: ProductTableViewController? // product-table-view-controller delegate
    
    // IBOutlet vaiables
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtId: UITextField!
    @IBOutlet weak var txtProductDescription: UITextView!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtProvider: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initial empty fields
        txtId.text = ""
        txtName.text = ""
        txtProvider.text = ""
        txtPrice.text = ""
        txtProductDescription.text = ""
        
     //   txtProductDescription.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.2) // adding border color
        txtProductDescription.layer.borderWidth = 1.0 // adding border width
        txtProductDescription.layer.cornerRadius = 5.0 // adding border radius
        if selectedProduct != nil{ // if selected product
            txtId.text = selectedProduct?.id // sets id
            txtName.text = selectedProduct?.name // sets name
            txtProvider.text = selectedProduct?.parentProvider!.name // sets provider
            txtPrice.text = String(selectedProduct!.price)// set price
            txtProductDescription.text = selectedProduct?.p_description // sets description
        }
    }
    
    @IBAction func saveBtnClick(_ sender: Any) {
        var message = ""
        
        // Check whether fields are empty
        if(txtId.text?.count == 0) {
            message = "Enter id of product"
        }else if (txtName.text?.count == 0){
            message = "Enter name product"
        }else if (txtProvider.text?.count == 0){
            message = "Enter provider name of product"
        }else if (txtPrice.text?.count == 0){
            message = "Enter price of product"
        }
        if(message != "") { // it means any error if this field not empty
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert) // set the alert object
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil) // set the OK button
            alert.addAction(okAction) // add the ok action button
            present(alert, animated: true, completion: nil) // alert button
        }else {
            let selectedProvider = selectedProduct?.parentProvider // gets the current selected provider
            if selectedProduct == nil { // if a new product
                selectedProduct = Product(context: delegate!.context) // create a new product object
            }
            
            selectedProduct?.id = txtId.text // set id value from field
            selectedProduct?.name = txtName.text // set name value from field
            selectedProduct?.p_description = txtProductDescription.text // set description value from field
            selectedProduct?.price = Double(txtPrice.text!)! // set price value from field
            
            var existingProvider = delegate?.getProviderByName(ProviderNameForSearch: txtProvider.text! ) // fetch existing provider using name
            if existingProvider == nil { // if not found
                existingProvider = Provider(context: delegate!.context) // create a new provider object
                existingProvider?.name = txtProvider.text! // provider name set
            }
            selectedProduct?.parentProvider = existingProvider // relationship product provider
            if selectedProduct == nil { // if it is a new product
                delegate?.products.append(selectedProduct!) // add product in array
            }else{
                // delete if provider changed for existing product & if last product of provider
                if selectedProvider != nil && existingProvider?.name != selectedProvider?.name && (selectedProvider?.products!.count)! < 1{
                    delegate?.context.delete(selectedProvider!)  // delete the provider
                }
            }
            do {
                try delegate?.context.save() // saves context
            } catch {
                print("Error saving the product \(error.localizedDescription)")  // print error
            }
            performSegue(withIdentifier: "dismissToProductViewController", sender: self) // dismiss modal popup view
        }
    }

    @IBAction func cancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil) // dismiss if cancel
    }
}

