//
//  TableScreen.swift
//  x&0Game
//
//  Created by Alexia Aldea on 20.04.2024.
//

import SwiftUI

struct TableScreen: View {
    @State var playerNameTurn: Int = 1
    @State var icon: ImageResource? = nil
    var body: some View {
        VStack {
            Text("It's player's \(playerNameTurn) turn!")
                .padding(.vertical, 32)
            
            ForEach(0..<3) { line in
                HStack(spacing: 8) {
                    ForEach(0..<3) { column in
                        switch playerNameTurn {
                        case 1:
                            Button {
                                self.icon = .icX
                            } label: {
                                TableCellView(icon: $icon) {
                                    self.playerNameTurn = 1
                                }
                            }
                        case 2:
                            Button {
                                self.icon = .ic0
                            } label: {
                                TableCellView(icon: $icon) {
                                    self.playerNameTurn = 2
                                }
                            }
                        default:
                            EmptyView()
                        }
                    }
                }
            }
        }.ignoresSafeArea()
    }
}

struct TableCellView: View {
    @Binding var icon: ImageResource?
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            if let icon = icon {
                Image(icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .padding(.all, 8)
                    .border(.mint, width: 2)
            } else {
                Rectangle()
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .padding(.all, 8)
                    .border(.mint, width: 2)
            }
        }
    }
}

#Preview {
    TableScreen()
}
