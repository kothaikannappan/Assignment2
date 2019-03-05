//
//  FilterService.swift
//  GetGoingClass
//
//  Created by Parijat Bandyopadhyay on 04/03/19.
//  Copyright © 2019 SMU. All rights reserved.
//

import Foundation
import CoreLocation

class FilterService: NSObject {
    
    // singleton
    static let shared = FilterService()
    
    
    weak var delegate: FilterServiceDelegate?
    
  
}


// Custom protocol
protocol FilterServiceDelegate: class {
    func applyFilter(rankBy: String?, rad: Double?, open: Bool?)
}

