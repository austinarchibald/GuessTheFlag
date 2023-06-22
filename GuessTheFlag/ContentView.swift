//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Austin Archibald on 6/20/23.
//

import SwiftUI

struct ContentView: View {
    @State private var showingScore = false // alert showing their progress
    @State private var scoreTitle = "" // message title in alert
    @State private var messageBody = ""
    
    @State private var countries = allCountries.shuffled() // randomize this for the game
    @State private var correctAnswer = Int.random(in: 0...2) // 3 flags showing at once
    static let allCountries = Array(CountryCodes.countryCodes.keys)
    
    @State private var score = 0
    @State private var gameOver = false
    @State private var rounds = 1
    @State private var highScore = 0
    
    private let defaults = UserDefaults.standard
    
    var body: some View {
        ZStack {
            RadialGradient(stops: [
                .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.3),
                .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.3),
            ], center: .top, startRadius: 200, endRadius: 400)
            .ignoresSafeArea()
            
            VStack {
                Spacer()
                Text("Guess The Flag")
                    .font(.title)
                    .foregroundStyle(.white)
                
                VStack(spacing: 15) { // having two VStacks allows us to position more precisely.
                    VStack {
                        Text("Tap the flag of")
                            .foregroundStyle(.secondary)
                            .font(.subheadline.weight(.heavy))
                        
                        Text(CountryCodes.countryCodes[countries[correctAnswer]] ?? "Unknown")
                            .font(.largeTitle.weight(.semibold)) // largest iOS font size, autoscales
                    }
                    ForEach(0..<3) { number in
                        Button {
                            flagTapped(number)
                        } label: {
                            Image(countries[number])
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200, maxHeight: 150)
                                .shadow(radius:10) // light shadow effect, no color: translucent black, no x/y: centered
//                                .padding()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Spacer()
                Spacer()
                
                Text("Score: \(score)")
                    .foregroundStyle(.white)
                    .font(.title.bold())
                
                Spacer()
                
                Text("Round: \(rounds)/10")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("High Score: \(highScore)")
                    .font(.footnote)
                    .foregroundStyle(.white)
            }
            .padding()
        }
        //score alert
        .alert(scoreTitle, isPresented: $showingScore) {
            Button("Continue", action: askQuestion)
        } message: {
            Text(messageBody)
        }
        //game over alert
        .alert("\(scoreTitle) Game Over", isPresented: $gameOver) {
            Button("Start New Game", action: resetGame)
        } message: {
            Text(messageBody)
        }
        .onAppear(perform: load)
    }
    
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct!"
            score += 1
            if rounds == 10 {
                messageBody = "Your final score is \(score)"
            } else {
                messageBody = "Your score is \(score)"
            }
        } else {
            scoreTitle = "Wrong."
            score -= 1
            if rounds == 10 {
                messageBody = "That's \(CountryCodes.countryCodes[countries[number]] ?? "Unknown")!\nYour final score is \(score)"
            } else {
                messageBody = "That's \(CountryCodes.countryCodes[countries[number]] ?? "Unknown")!\nYour score is \(score)"
            }
        }
        
        (rounds == 10) ? (gameOver = true) : (showingScore = true)
    }
    
    func askQuestion() {
        countries.remove(at: correctAnswer)
        countries.shuffle() // to make countries & correctAnswer mutable, need to @State the vars above
        correctAnswer = Int.random(in: 0..<2)
        rounds += 1
    }
    
    func resetGame() {
        if score > highScore {
            highScore = score
            defaults.set(highScore, forKey: "highScore")
        }
        rounds = 0
        score = 0
        countries = Self.allCountries
        askQuestion()
    }
    
    func load() {
        let savedHighScore = defaults.integer(forKey: "highScore")
        highScore = savedHighScore
    }
}

#Preview {
    ContentView()
}
