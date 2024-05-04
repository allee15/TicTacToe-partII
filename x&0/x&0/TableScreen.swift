//
//  TableScreen.swift
//  x&0Game
//
//  Created by Alexia Aldea on 20.04.2024.
//

import SwiftUI

struct TableScreen: View {
    @State var playerNameTurn: Int = 1
    @State var icons: [[ImageResource?]] = Array(repeating: Array(repeating: nil, count: 3), count: 3)

    var body: some View {
        VStack {
            Text("It's player \(playerNameTurn)'s turn!")
                .padding(.vertical, 32)
            
            ForEach(0..<3) { row in
                HStack(spacing: 8) {
                    ForEach(0..<3) { column in
                        Button {
                            icons[row][column] = playerNameTurn == 1 ? .icX : .ic0
                            playerNameTurn = playerNameTurn == 1 ? 2 : 1
                        } label: {
                            TableCellView(icon: $icons[row][column])
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
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



