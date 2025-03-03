//
//  ContentView.swift
//  MC3
//
//  Created by Vanessa on 11/07/24.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    @ObservedObject var cardViewModel = CardViewModel()
    @ObservedObject var statisticsViewModel = StatisticsViewModel()
    @Environment(\.colorScheme) var colorScheme
    @State var goToStatisticDetail = false
    @Query var exercises: [Exercise]
    @State private var totalDuration: String = "0"
    @State private var averageAccuracy: Int = 0

    
    var body: some View {
        NavigationStack {
                ScrollView{
                    HStack {
                        Text("Train My Footwork")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                            .padding([.leading], 16.0)
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                                                Image(systemName: "person.circle")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(Color("Accent"))
                                            }
                                            .padding(.trailing, 16.0)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Tips and Tricks")
                            .font(.system(size: 13))
                            .padding([.leading, .top], 16.0)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(cardViewModel.cardData) { card in
                                    CardView(card: card)
                                }
                            }
                            .padding([.leading, .bottom])
                        }
                    }
                    
                    // Statistics Detail
                    VStack {
                        HStack {
                            Text("Statistics Detail")
                                .font(.system(size: 13))
                                .padding(.top, -5.0)
                            Spacer()
                            Text("Show More")
                                .font(.system(size: 13))
                                .underline()
                                .padding(.top, -5.0)
                                .onTapGesture {
                                    goToStatisticDetail = true
                                }
                                .navigationDestination(isPresented: $goToStatisticDetail) {
                                    StatisticsList()
                                }
                        }
                        Spacer()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("\(statisticsViewModel.getTotalDuration())")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Time")
                                    .font(.caption)
                                    .foregroundColor(Color("Gray"))
                            }
                            
                            VStack(alignment: .leading) {
                                Text("\(statisticsViewModel.getAverageAccuracy())%")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Accuracy")
                                    .font(.caption)
                                    .foregroundColor(Color("Gray"))
                            }
                            .padding(.leading, 32.0)
                            Spacer()
                        }
                        .padding(.leading)
                        
                        GeometryReader { geometry in
                            let data = statisticsViewModel.statistics.map { $0.value }
                            let months = statisticsViewModel.statistics.map { $0.month }
                            
                            let width = geometry.size.width
                            let height = geometry.size.height
                            
                            let maxData = data.max() ?? 1
                            let minData = 0.0
                            let steps = maxData == 1 ? 1 : maxData / 5
                            
                            let barWidth = width / CGFloat(data.count * 2)
                            let yScale = height / CGFloat(maxData - minData)
                            
                            ZStack {
                                // Sumbu Y
                                Path { path in
                                    path.move(to: CGPoint(x: 30, y: height))
                                    path.addLine(to: CGPoint(x: 30, y: 0))
                                    
                                    path.move(to: CGPoint(x: 30, y: height))
                                    path.addLine(to: CGPoint(x: width, y: height))
                                }
                                .stroke(Color.gray, lineWidth: 1)
                                
                                // Garis data
                                ForEach(0..<data.count, id: \.self) { index in
                                    let xPosition = CGFloat(index) * (barWidth * 2) + 40
                                    let barHeight = CGFloat(data[index] - minData) * yScale
                                    
                                    Path { path in
                                        path.addRect(CGRect(x: xPosition, y: height - barHeight, width: barWidth, height: barHeight))
                                    }
                                    .fill(Color("Accent"))
                                }
                                
                                ForEach(0..<data.count, id: \.self) { index in
                                    Text(months[index])
                                        .font(.caption)
                                        .position(x: CGFloat(index) * (barWidth * 2) + barWidth / 2 + 40, y: height + 10)
                                }
                                
                                ForEach(Array(stride(from: minData, through: maxData, by: steps)), id: \.self) { value in
                                    Text("\(Int(value))")
                                        .font(.caption)
                                        .position(x: 15, y: height - CGFloat(value - minData) * yScale)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding([.top, .bottom, .trailing], 20.0)
                    }
                    .padding(.horizontal)
                    
                    // Navigasi ke TrainView
                    NavigationLink(destination: trainView()) {
                        Text("Start")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 118, height: 118)
                            .background(Color("Accent"))
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .padding(.bottom, 10.0)
//                            .padding(.top, 10)
                    }
                }
                .background(Color("Primary").edgesIgnoringSafeArea(.all))
                .navigationBarHidden(false)
                
                .onAppear{
                    goToStatisticDetail = false
                    statisticsViewModel.exercises = self.exercises
                    statisticsViewModel.getMonthlyStatistic()
                }
                //            .navigationTitle("Train Foot work")
//            }
        }
        
    }
}

struct CardView: View {
    let card: CardData
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: DetailView(card: card)) {
            HStack(alignment: .center) {
                Image(card.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 81, height: 81)
                    .cornerRadius(10)
                    .clipped()
                
                VStack(alignment: .leading) {
                    Text(card.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(Color("Gray"))
                    Text(card.title)
                        .font(.system(size: 17))
                        .fontWeight(.bold)
                        .foregroundColor(Color.primary) // This will adapt to light/dark mode
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .truncationMode(.tail)
                    
                    
                    HStack {
                        Label(card.duration, systemImage: "clock")
                            .foregroundColor(Color("Gray"))
                    }
                    .font(.caption)
                }
                .padding(.vertical, 10)
            }
            .padding()
            .background(Color("Primary"))
            .cornerRadius(15)
            .shadow(color: colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
            .frame(width: 270)
            .padding(.vertical, 10)
        }
    }
}



#Preview {
    ContentView()
}


