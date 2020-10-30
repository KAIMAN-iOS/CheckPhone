//
//  File.swift
//  
//
//  Created by GG on 30/10/2020.
//

import UIKit
import KCoordinatorKit

class CheckPhoneCoordinator<DeepLinkType>: Coordinator<DeepLinkType> {
    let checkController: CheckPhoneController = CheckPhoneController.create()
    init(router: RouterType, phone: String) {
        super.init(router: router)
        checkController.phoneNumber = phone
    }
    
    override func toPresentable() -> UIViewController {
        checkController
    }
}
