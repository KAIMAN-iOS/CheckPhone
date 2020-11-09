//
//  File.swift
//  
//
//  Created by GG on 30/10/2020.
//

import UIKit
import KCoordinatorKit

public class CheckPhoneCoordinator<DeepLinkType>: Coordinator<DeepLinkType> {
    public let checkController: CheckPhoneController = CheckPhoneController.create()
    public init(router: RouterType, phone: String) {
        super.init(router: router)
        checkController.phoneNumber = phone
    }
    
    deinit {
        print("💀 DEINIT \(URL(fileURLWithPath: #file).lastPathComponent)")
    }
    
    public override func toPresentable() -> UIViewController {
        checkController
    }
}

extension String {
    func bundleLocale() -> String {
        NSLocalizedString(self, bundle: .module, comment: self)
    }
}

