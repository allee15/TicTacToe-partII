//
//  TableScreen.swift
//  x&0Game
//
//  Created by Alexia Aldea on 20.04.2024.
//

import SwiftUI

class TableViewModel: ObservableObject {
    @Published var playerNameTurn: Int = 1
    @Published var icons: [[ImageResource?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)
    @Published var winner: Int? = nil
    @Published var isGameOver = false
    
    func checkWinner() {
        for row in icons {
            if row[0] != nil && row[0] == row[1] && row[1] == row[2] {
                winner = playerNameTurn
                return
            }
        }
        
        for column in 0..<3 {
            if icons[0][column] != nil && icons[0][column] == icons[1][column] && icons[1][column] == icons[2][column] {
                winner = playerNameTurn
                return
            }
        }
        
        if icons[0][0] != nil && icons[0][0] == icons[1][1] && icons[1][1] == icons[2][2] {
            winner = playerNameTurn
            return
        }
        if icons[0][2] != nil && icons[0][2] == icons[1][1] && icons[1][1] == icons[2][0] {
            winner = playerNameTurn
            return
        }
        
        if !icons.map({ $0 }).contains(nil) {
            winner = 0
            return
        }
    }
    
    func reset() {
        playerNameTurn = 1
        icons = Array(repeating: Array(repeating: nil, count: 3), count: 3)
        winner = nil
    }
}

struct TableScreen: View {
    @EnvironmentObject private var navigation: Navigation
    @StateObject private var viewModel = TableViewModel()
    
    var body: some View {
        VStack {
            Text("It's player \(viewModel.playerNameTurn)'s turn!")
                .padding(.vertical, 32)
            
            ForEach(0..<3) { row in
                HStack(spacing: 8) {
                    ForEach(0..<3) { column in
                        Button {
                            if viewModel.winner == nil {
                                viewModel.icons[row][column] = viewModel.playerNameTurn == 1 ? .icX : .ic0
                                viewModel.playerNameTurn = viewModel.playerNameTurn == 1 ? 2 : 1
                                
                                viewModel.checkWinner()
                                
                                if viewModel.winner != nil {
                                    viewModel.isGameOver = true
                                }
                            }
                        } label: {
                            TableCellView(icon: $viewModel.icons[row][column])
                        }
                    }
                }
            }
        }.padding(.horizontal, 16)
            .ignoresSafeArea(.all)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: viewModel.isGameOver) { _ in
                let modal = ModalView(title: viewModel.winner == 0 ? "It's a tie!" : "Player \(viewModel.winner) wins!",
                                      topButtonText: "Close") {
                    viewModel.reset()
                    navigation.dismissModal(animated: true, completion: nil)
                }
                navigation.presentPopup(modal.asDestination(), animated: true, completion: nil)
            }
    }
}

struct TableCellView: View {
    @Binding var icon: ImageResource?
    
    var body: some View {
        if let icon = icon {
            Image(icon)
                .resizable()
                .frame(width: 32, height: 32)
                .padding(.all, 8)
                .border(.mint, width: 2)
        } else {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .padding(.all, 8)
                .border(.mint, width: 2)
        }
    }
}

struct ModalView: View {
    let title: String
    let topButtonText: String
    let onTopButtonTapped: () -> ()
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack(spacing: 0) {
                
                Text(title)
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 20)
                
                Button {
                    onTopButtonTapped()
                } label: {
                    Text(topButtonText)
                        .font(.system(size: 14))
                        .padding(.all, 12)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .background(Color.mint)
                    
                }
            }.padding(.horizontal, 24)
                .padding(.vertical, 36)
                .background(Color.white.cornerRadius(8))
                .padding(.horizontal, 24)
        }.ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

