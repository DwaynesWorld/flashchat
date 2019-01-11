//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextfield.text = "k@k.com"
        passwordTextfield.text = "123456"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func logInPressed(_ sender: AnyObject) {
        guard let email = emailTextfield.text, let password = passwordTextfield.text else {
            return
        }
        
        SVProgressHUD.show()
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            SVProgressHUD.dismiss()
            
            if let error = error {
                print(error)
            } else {
                print("Login Success!")
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    }
}  
