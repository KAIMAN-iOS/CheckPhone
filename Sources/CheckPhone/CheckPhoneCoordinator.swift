//
//  File.swift
//  
//
//  Created by GG on 30/10/2020.
//

import UIKit
import KCoordinatorKit
import ATAConfiguration

protocol CloseDelegate: NSObjectProtocol {
    func close(_ controller: UIViewController)
}

public class CheckPhoneCoordinator<DeepLinkType>: Coordinator<DeepLinkType> {
    public enum Mode { case standalone, embeeded}
    public var checkController: CheckPhoneController!
    var mode: Mode = .embeeded
    var modalDelegate: UIAdaptivePresentationControllerDelegate?
    public init(router: RouterType,
                phone: String, conf: ATAConfiguration,
                modalDelegate: UIAdaptivePresentationControllerDelegate? = nil,
                mode: Mode = .embeeded) {
        super.init(router: router)
        self.mode = mode
        self.modalDelegate = modalDelegate
        checkController = CheckPhoneController.create(conf: conf)
        checkController.closeDelegate = self
        checkController.phoneNumber = phone
    }
    
    deinit {
        print("💀 DEINIT \(URL(fileURLWithPath: #file).lastPathComponent)")
    }
    
    public override func toPresentable() -> UIViewController {
        checkController.isModalInPresentation = true
        router.navigationController.presentationController?.delegate = modalDelegate
        switch mode {
        case .embeeded: return checkController
        case .standalone:
            let nav = UINavigationController(rootViewController: checkController)
            checkController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
            return nav
        }
    }
    
    @objc func cancel() {
        close(checkController)
    }
}

extension String {
    func bundleLocale() -> String {
        NSLocalizedString(self, bundle: .module, comment: self)
    }
}

extension CheckPhoneCoordinator: CloseDelegate {
    func close(_ controller: UIViewController) {
        checkController.verifyCompletion?(.success(false))
        checkController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
