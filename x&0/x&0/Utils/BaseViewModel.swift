//
//  BaseViewModel.swift
//  x&0Game
//
//  Created by Alexia Aldea on 20.04.2024.
//

import Foundation
import Combine

class BaseViewModel: ObservableObject {
    var bag = Set<AnyCancellable>()
}
