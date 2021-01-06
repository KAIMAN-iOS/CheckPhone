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
import ATAConfiguration

public enum CheckCodeError: Error {
    case verificationCodeMissing
    case invalidVerificationCode
}

/// Provides a common entry to check a phone number
///
/// based on https://firebase.google.com/docs/auth/ios/phone-auth
public class CheckPhoneController: UIViewController {
    static var configuration: ATAConfiguration!
    static func create(conf: ATAConfiguration) -> CheckPhoneController {
        CheckPhoneController.configuration = conf
        return UIStoryboard(name: "CheckPhone", bundle: .module).instantiateViewController(withIdentifier: "CheckPhoneController") as! CheckPhoneController
    }
    @IBOutlet weak var titleLabel: UILabel!  {
        didSet {
            titleLabel.set(text: "Check number title".bundleLocale(), for: .largeTitle, textColor: CheckPhoneController.configuration.palette.mainTexts)
        }
    }

    @IBOutlet weak var checkLabel: UILabel!  {
        didSet {
            checkLabel.set(text: String(format: "Check number message format", phoneNumber).bundleLocale(), for: .body, textColor: CheckPhoneController.configuration.palette.mainTexts)
        }
    }

    @IBOutlet weak var receiveLabel: UILabel!  {
        didSet {
            receiveLabel.set(text: "didn't receive code".bundleLocale(), for: .body, textColor: CheckPhoneController.configuration.palette.mainTexts)
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
    public var selectTextFieldOnSendComplete: Bool = true
    
    /**
     the phone number to send the code to
     
     - important:
     if you don't specify the phone number, a fatalError will be raised at load
     */
    var phoneNumber: String = ""
    @IBOutlet weak var resendButton: UIButton!  {
        didSet {
            resendButton.setTitle("Resend code".bundleLocale(), for: .normal)
            resendButton.setTitleColor(CheckPhoneController.configuration.palette.primary, for: .normal)
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
        checkLabel.set(text: "sending code".bundleLocale(), for: .body, textColor: CheckPhoneController.configuration.palette.mainTexts)
        let loader = UIActivityIndicatorView(style: .medium)
        loader.color = CheckPhoneController.configuration.palette.primary
        receiveStackView.addArrangedSubview(loader)
        loader.startAnimating()
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { [weak self, phoneNumber] (verificationId, error) in
            self?.verificationId = verificationId
            self?.checkLabel.set(text: String(format: "Check number message format".bundleLocale(), phoneNumber), for: .body, textColor: CheckPhoneController.configuration.palette.mainTexts)
            loader.removeFromSuperview()
            self?.receiveStackView.removeArrangedSubview(loader)
            
            if self?.selectTextFieldOnSendComplete ?? false {
                self?.pinCodeView.becomeFirstResponder()
            }
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false )
        navigationController?.navigationBar.prefersLargeTitles = false
        title = nil
    }
    
    private (set) var verificationId: String?
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        pinFieldSetUpCompletion?(pinCodeView)
        guard phoneNumber.count > 0 else {
            fatalError("A phone number must be set in order to use CheckPhone")
        }
        resendCode()
        checkLabel.set(text: String(format: "Check number message format".bundleLocale(), phoneNumber), for: .body, textColor: CheckPhoneController.configuration.palette.mainTexts)
    }
    
    private func configureDefaultPinCode() {
        pinCodeView.properties.numberOfCharacters = 6
        // appearance
        pinCodeView.appearance.textColor = CheckPhoneController.configuration.palette.mainTexts
        pinCodeView.appearance.tokenColor = CheckPhoneController.configuration.palette.inactive
        pinCodeView.appearance.tokenFocusColor = CheckPhoneController.configuration.palette.primary
        pinCodeView.appearance.keyboardType = UIKeyboardType.numberPad // Specify keyboard type
    }
}
