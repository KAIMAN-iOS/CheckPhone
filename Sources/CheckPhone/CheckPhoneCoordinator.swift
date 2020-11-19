//
//  File.swift
//  
//
//  Created by GG on 30/10/2020.
//

import UIKit
import KCoordinatorKit
import ATAConfiguration

public class CheckPhoneCoordinator<DeepLinkType>: Coordinator<DeepLinkType> {
    public var checkController: CheckPhoneController!
    public init(router: RouterType, phone: String, conf: ATAConfiguration) {
        super.init(router: router)
        checkController = CheckPhoneController.create(conf: conf)
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

