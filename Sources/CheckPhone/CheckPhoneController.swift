//
//  File.swift
//  
//
//  Created by GG on 15/10/2020.
//

import UIKit
import FirebaseAuth

/// Provides a common entry to check a phone number
///
/// based on https://firebase.google.com/docs/auth/ios/phone-auth
class CheckPhoneController: UIViewController {
    static func create() -> CheckPhoneController {
        return Bundle.module.loadNibNamed("CheckPhoneController", owner: nil, options: nil)?.first as! CheckPhoneController
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkLabel: UILabel!
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var pinCodeView: KAPinField!  {
        didSet {
            configureDefaultPinCode()
        }
    }
    /// use pinFieldSetUpCompletion if you want to customize the pinCode Field
    ///
    /// see configureDefaultPinCode() for an axample of options
    let pinFieldSetUpCompletion: ((KAPinField) -> Void)? = nil
    
    let verifyCompletion: ((Result<Bool, Error>) -> Void)? = nil
    
    /**
     the phone number to send the code to
     
     - important:
     if you don't specify the phone number, a fatalError will be raised at load
     */
    var phoneNumber: String = ""

    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBAction func checkCode() {
        guard let code = pinCodeView.text,
              let id = verificationId else {
            return
        }
        Auth.auth().languageCode = "fr"
        let credential = PhoneAuthProvider
            .provider()
            .credential(
            withVerificationID: id,
                verificationCode: code)
        
        Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
            guard error == nil else {
                self?.verifyCompletion?(.failure(error!))
                return
            }
            self?.verifyCompletion?(.success(true))
        }
    }
    
    @IBAction func resendCode() {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self] (verificationId, error) in
            self?.verificationId = verificationId
        }
    }
    
    private (set) var verificationId: String?
    override func viewDidLoad() {
        pinFieldSetUpCompletion?(pinCodeView)
        guard phoneNumber.count > 0 else {
            fatalError("A phone number must be set in order to use CheckPhone")
        }
        resendCode()
    }
    
    private func configureDefaultPinCode() {
        pinCodeView.properties.animateFocus = true // Animate the currently focused token
        pinCodeView.properties.isSecure = false // Secure pinField will hide actual input
        // appearance
        pinCodeView.appearance.backBorderWidth = 1
        pinCodeView.appearance.backBorderColor = UIColor.lightGray
        pinCodeView.appearance.backCornerRadius = 4
        pinCodeView.appearance.backFocusColor = UIColor.clear
        pinCodeView.appearance.backBorderFocusColor = UIColor.white.withAlphaComponent(0.8)
        pinCodeView.appearance.backActiveColor = UIColor.blue.withAlphaComponent(0.3)
        pinCodeView.appearance.backBorderActiveColor = UIColor.blue
        pinCodeView.appearance.keyboardType = UIKeyboardType.numberPad // Specify keyboard type
    }
}
