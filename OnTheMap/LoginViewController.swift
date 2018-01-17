//
//  ViewController.swift
//  OnTheMap
//
//  Created by Sarah Howe on 9/10/15.
//  Copyright (c) 2015 SarahHowe. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    //MARK --- Outlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    //MARK --- Variables
    
    var appDelegate: AppDelegate!
    var session: URLSession!
    
    var tapRecognizer: UITapGestureRecognizer? = nil
    
    //MARK --- Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //get the app delegate
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //get the shared url session
        session = URLSession.shared
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //set placeholder text color
        //Found out how to do this from this stackoverflow topic: http://stackoverflow.com/questions/26076054/changing-placeholder-text-color-with-swift
        emailTextField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        //add a little left indent/padding on the text fields
        //Found how to do this from this stackoverflow topic: http://stackoverflow.com/questions/7565645/indent-the-text-in-a-uitextfield
        let emailSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        emailTextField.leftViewMode = UITextFieldViewMode.always
        emailTextField.leftView = emailSpacerView
        let passwordSpacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        passwordTextField.leftViewMode = UITextFieldViewMode.always
        passwordTextField.leftView = passwordSpacerView
        
        loginButton.isEnabled = false
        
        //initialize tap recognizer
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleSingleTap(_:)))
        tapRecognizer!.numberOfTapsRequired = 1
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        //add the tap recognizer
        addKeyboardDismissRecognizer()
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        //remove the tap recognizer
        removeKeyboardDismissRecognizer()
        
        emailTextField.text = ""
        passwordTextField.text = ""
        loginButton.isEnabled = false
    }
    
    //MARK --- Actions
    
    @IBAction func loginToUdacity(_ sender: UIButton)
    {
        dismissAnyVisibleKeyboards()
        
        UdacityClient.sharedInstance().createSession(emailTextField.text!, password: passwordTextField.text!) { message, error in
            
            if let error = error
            {
                print("Login failed: \(message)")
                
                //get the description of the specific error that results from the failed request
                let failureString = error.localizedDescription
                
                //if the error string contains the word server, it's a server error not a password error
                if(failureString.range(of: "server") != nil)
                {
                    self.displayError("\(failureString)")
                }
                else
                {
                    self.shakeView()
                }
            }
            else
            {
                print("login complete! \(message)")
                self.completeLogin()
            }
        }
    }
    
    @IBAction func signUpWithUdacity(_ sender: UIButton)
    {
        let url = URL(string: "https://www.google.com/url?q=https://www.udacity.com/account/auth%23!/signin&sa=D&usg=AFQjCNHOjlXo3QS15TqT0Bp_TKoR9Dvypw")!
        UIApplication.shared.openURL(url)
    }
    
    //MARK --- Login Behavior
    
    func completeLogin()
    {
        DispatchQueue.main.async(execute: {
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "UserTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        })
    }
    
    func shakeView()
    {
        DispatchQueue.main.async(execute: {
            
            //learned how to make a shake animation from this website: http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.07
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: self.view.center.x - 5, y: self.view.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: self.view.center.x + 5, y: self.view.center.y))
            self.view.layer.add(animation, forKey: "position")
        })
    }
    
    func displayError(_ errorString: String?)
    {
        UdacityClient.sharedInstance().loginError = errorString
        
        DispatchQueue.main.async(execute: {
            
            //learned how to implement an alert controller from this website: http://swiftoverload.com/uialertcontroller-swift-example/
            let alert: UIAlertController = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: .alert)
            let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        })
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField)
    {
        if(emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty)
        {
            loginButton.isEnabled = false
        }
        else
        {
            loginButton.isEnabled = true
        }
    }
    
    //MARK --- Keyboard Helpers
    
    //dismiss the keyboard
    func addKeyboardDismissRecognizer()
    {
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer()
    {
        view.removeGestureRecognizer(tapRecognizer!)
    }
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer)
    {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        return true
    }
}

extension LoginViewController {
    
    func dismissAnyVisibleKeyboards()
    {
        if(emailTextField.isFirstResponder || passwordTextField.isFirstResponder)
        {
            view.endEditing(true)
        }
    }
}
