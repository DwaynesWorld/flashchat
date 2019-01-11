//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    @IBAction func registerPressed(_ sender: AnyObject) {
        guard
            let email = emailTextfield.text,
            let password = passwordTextfield.text
            else { return }
        
        SVProgressHUD.show()
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            SVProgressHUD.dismiss()
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Registration Successful: \(user!)")
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    } 
    
    
}
