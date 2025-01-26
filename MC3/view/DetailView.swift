//
//  DetailView.swift
//  MC3
//
//  Created by Vanessa on 14/07/24.
//

import SwiftUI

struct DetailView: View {
    let card: CardData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(card.subtitle)
                    .font(.subheadline)
                    .foregroundColor(Color("Gray"))
                Text(card.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 5)

                HStack {
                    Text("by \(card.author)")
                        .padding(.trailing, 8)
                    Text("|")
                        .padding(.trailing, 8)
                    Text(card.date)
                        .padding(.trailing, 8)
                    Text("|")
                        .padding(.trailing, 8)
                    Text(card.duration)
                }
                .font(.caption)
                .foregroundColor(Color("Gray"))
                .padding(.bottom, 10)

                Image(card.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .padding(.bottom, 10)

                Text(card.detail)
                    .padding(.bottom, 5)
            }
            .padding()
            .navigationTitle(card.title)
            .background(Color("Primary").edgesIgnoringSafeArea(.all))
        }
    }
}
