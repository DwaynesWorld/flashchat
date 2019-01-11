//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messages: [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextfield.delegate = self
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        retrieveMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: Notification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: Notification.Name.UIKeyboardWillHide,
            object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            UIView.animate(withDuration: 0.4, animations: {
                self.heightConstraint.constant = (keyboardHeight + 16)
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.4, animations: {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        cell.messageBody.text = messages[indexPath.row].text
        cell.senderUsername.text = messages[indexPath.row].sender
        cell.avatarImageView.image = #imageLiteral(resourceName: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatWatermelon()
            cell.messageBackground.backgroundColor = UIColor.flatGray()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
        messageTableView.separatorStyle = .none
    }
    
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    //MARK:- TextField Delegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    //MARK: - Send & Recieve from Firebase
    
    func retrieveMessages() {
        let messageDB = Database.database().reference().child("messages")
        messageDB.observe(.childAdded) { (snapshot) in
            guard
                let data = snapshot.value as? Dictionary<String, String>,
                let text = data["text"],
                let sender = data["sender"]
                else { return }
                
            let message = Message()
            message.text = text
            message.sender = sender
            
            self.messages.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        guard
            let text = messageTextfield.text,
            let user = Auth.auth().currentUser
            else {
                messageTextfield.isEnabled = true
                sendButton.isEnabled = true
                return
        }
        
        let messageDB = Database.database().reference().child("messages")
        let message = [ "sender": user.email, "text": text ]
        
        messageDB.childByAutoId().setValue(message) { (error, ref) in
            if let error = error {
                print(error)
            } else {
                print("message saved sucessfully")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
        
        guard navigationController?.popToRootViewController(animated: true) != nil else {
            print("No View Controllers to popoff!")
            return
        }
    }
}
