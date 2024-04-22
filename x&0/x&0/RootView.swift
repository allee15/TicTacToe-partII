//
//  ContentView.swift
//  x&0Game
//
//  Created by Alexia Aldea on 16.04.2024.
//

import SwiftUI
import Combine

class RootViewModel: BaseViewModel {
    
    private var isBinded = false
    
    func bind() {
        if isBinded {return}
        isBinded = true
    }
}

struct RootView: View {
    @ObservedObject var navigation: Navigation
    @StateObject var viewModel = RootViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationHostView(navigation: navigation)
                .onAppear {
                    viewModel.bind()
                }
        }
        .ignoresSafeArea()
    }
    
}


