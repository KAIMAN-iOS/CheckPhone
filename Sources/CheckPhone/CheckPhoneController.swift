//
//  File.swift
//  
//
//  Created by GG on 15/10/2020.
//

import UIKit
import FirebaseAuth
import LabelExtension
import FontExtension
import ActionButton

public enum CheckCodeError: Error {
    case verificationCodeMissing
    case invalidVerificationCode
}

/// Provides a common entry to check a phone number
///
/// based on https://firebase.google.com/docs/auth/ios/phone-auth
public class CheckPhoneController: UIViewController {
    static func create() -> CheckPhoneController {
        return UIStoryboard(name: "CheckPhone", bundle: .module).instantiateViewController(withIdentifier: "CheckPhoneController") as! CheckPhoneController
    }
    @IBOutlet weak var titleLabel: UILabel!  {
        didSet {
            titleLabel.set(text: "Check number title".bundleLocale(), for: FontType.bigTitle, textColor: #colorLiteral(red: 0.1234303191, green: 0.1703599989, blue: 0.2791167498, alpha: 1))
        }
    }

    @IBOutlet weak var checkLabel: UILabel!  {
        didSet {
            checkLabel.set(text: String(format: "Check number message format", phoneNumber).bundleLocale(), for: FontType.default, textColor: #colorLiteral(red: 0.1234303191, green: 0.1703599989, blue: 0.2791167498, alpha: 1))
        }
    }

    @IBOutlet weak var receiveLabel: UILabel!  {
        didSet {
            receiveLabel.set(text: "didn't receive code".bundleLocale(), for: FontType.default, textColor: #colorLiteral(red: 0.1234303191, green: 0.1703599989, blue: 0.2791167498, alpha: 1))
        }
    }
    
    @IBOutlet weak var receiveStackView: UIStackView!

    @IBOutlet weak var pinCodeView: KAPinField!  {
        didSet {
            configureDefaultPinCode()
        }
    }
    /// use pinFieldSetUpCompletion if you want to customize the pinCode Field
    ///
    /// see configureDefaultPinCode() for an axample of options
    public var pinFieldSetUpCompletion: ((KAPinField) -> Void)? = nil
    public var verifyCompletion: ((Result<Bool, Error>) -> Void)? = nil
    
    /**
     the phone number to send the code to
     
     - important:
     if you don't specify the phone number, a fatalError will be raised at load
     */
    var phoneNumber: String = ""
    @IBOutlet weak var resendButton: UIButton!  {
        didSet {
            resendButton.setTitle("Resend code".bundleLocale(), for: .normal)
            resendButton.setTitleColor(#colorLiteral(red: 1, green: 0.192286253, blue: 0.2298730612, alpha: 1), for: .normal)
        }
    }

    @IBOutlet weak var checkButton: ActionButton!  {
        didSet {
            checkButton.shape = .rounded(value: 5.0)
            checkButton.actionButtonType = .primary
            checkButton.setTitle("check".bundleLocale(), for: .normal)
        }
    }
    
    deinit {
        print("💀 DEINIT \(URL(fileURLWithPath: #file).lastPathComponent)")
    }
    
    public func resetButtonState() {
        checkButton.isLoading = false
    }
    
    @IBAction func checkCode() {
        guard let code = pinCodeView.text,
              let id = verificationId else {
            verifyCompletion?(Result.failure(CheckCodeError.verificationCodeMissing))
            return
        }
        checkButton.isLoading = true
        Auth.auth().languageCode = "fr"
        let credential =
            PhoneAuthProvider
            .provider()
            .credential(
            withVerificationID: id,
                verificationCode: code)
        
        Auth
            .auth()
            .signIn(with: credential) { [weak self] (authResult, error) in
            guard error == nil else {
                if let authError = error,
                   let errCode = AuthErrorCode(rawValue: authError._code) {
                    switch errCode {
                    case .invalidVerificationCode: self?.verifyCompletion?(.failure(CheckCodeError.invalidVerificationCode))
                    default: self?.verifyCompletion?(.failure(error!))
                    }
                } else {
                    self?.verifyCompletion?(.failure(error!))
                }
                self?.resetButtonState()
                return
            }
            self?.verifyCompletion?(.success(true))
        }
    }
    
    @IBAction func resendCode() {
        checkLabel.set(text: "sending code".bundleLocale(), for: FontType.default, textColor: #colorLiteral(red: 0.1234303191, green: 0.1703599989, blue: 0.2791167498, alpha: 1))
        let loader = UIActivityIndicatorView(style: .white)
        loader.color = #colorLiteral(red: 1, green: 0.192286253, blue: 0.2298730612, alpha: 1)
        receiveStackView.addArrangedSubview(loader)
        loader.startAnimating()
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self, phoneNumber] (verificationId, error) in
            self?.verificationId = verificationId
            self?.checkLabel.set(text: String(format: "Check number message format".bundleLocale(), phoneNumber), for: FontType.default, textColor: #colorLiteral(red: 0.1234303191, green: 0.1703599989, blue: 0.2791167498, alpha: 1))
            loader.removeFromSuperview()
            self?.receiveStackView.removeArrangedSubview(loader)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false )
    }
    
    private (set) var verificationId: String?
    public override func viewDidLoad() {
        pinFieldSetUpCompletion?(pinCodeView)
        guard phoneNumber.count > 0 else {
            fatalError("A phone number must be set in order to use CheckPhone")
        }
        resendCode()
        checkLabel.set(text: String(format: "Check number message format".bundleLocale(), phoneNumber), for: FontType.default, textColor: #colorLiteral(red: 0.1234303191, green: 0.1703599989, blue: 0.2791167498, alpha: 1))
    }
    
    private func configureDefaultPinCode() {
        pinCodeView.properties.numberOfCharacters = 6
        // appearance
        pinCodeView.appearance.textColor = #colorLiteral(red: 0.1234303191, green: 0.1703599989, blue: 0.2791167498, alpha: 1)
        pinCodeView.appearance.tokenColor = #colorLiteral(red: 0.6176490188, green: 0.6521512866, blue: 0.7114837766, alpha: 1)
        pinCodeView.appearance.tokenFocusColor = #colorLiteral(red: 1, green: 0.192286253, blue: 0.2298730612, alpha: 1)
        pinCodeView.appearance.keyboardType = UIKeyboardType.numberPad // Specify keyboard type
    }
}
