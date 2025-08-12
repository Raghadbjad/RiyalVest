//
//  Stock.swift
//  RiyalVest
//
//  Created by Raghad on 10/09/1446 AH.
//

import Foundation
import Combine

struct Stock: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let price: String
    let change: String
    let changePercent: String
    let name: String
}
