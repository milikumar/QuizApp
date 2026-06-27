//
//  ContentView.swift
//  QuizApp
//
//  Created by Mili Kumar on 6/22/26.
//

import SwiftUI

struct Question {
    let text: String
    let options: [String]
    let correctAnswer: String
}

struct ContentView: View {
    
    let questionSets: [[Question]] = [
        [
            // random set
        Question(text: "What is the capital of Australia?",
                    options: ["Sydney", "Melbourne", "Canberra", "Brisbane"],
                    correctAnswer: "Canberra"),
        Question(text: "How many bones are in the human body?",
                    options: ["196", "206", "216", "226"],
                    correctAnswer: "206"),
        Question(text: "What is the largest ocean on Earth?",
                    options: ["Atlantic", "Indian", "Arctic", "Pacific"],
                    correctAnswer: "Pacific"),
        Question(text: "Which planet has the most moons?",
                    options: ["Jupiter", "Saturn", "Uranus", "Neptune"],
                    correctAnswer: "Saturn"),
        Question(text: "What year did World War II end?",
                    options: ["1943", "1944", "1945", "1946"],
                    correctAnswer: "1945"),
        Question(text: "What is the chemical symbol for gold?",
                    options: ["Go", "Gd", "Au", "Ag"],
                    correctAnswer: "Au"),
        Question(text: "How many hearts does an octopus have?",
                    options: ["1", "2", "3", "4"],
                    correctAnswer: "3"),
        Question(text: "What is the capital of Japan?",
                    options: ["Beijing", "Seoul", "Tokyo", "Bangkok"],
                    correctAnswer: "Tokyo"),
        Question(text: "Which country has the longest coastline?",
                    options: ["Russia", "USA", "Australia", "Canada"],
                    correctAnswer: "Canada"),
        Question(text: "What is the speed of light in km/s?",
                    options: ["200,000", "300,000", "400,000", "500,000"],
                    correctAnswer: "300,000"),
    ],
    [
        // science and nature set
        Question(text: "What gas do plants absorb from the atmosphere?",
                 options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Hydrogen"],
                 correctAnswer: "Carbon Dioxide"),
        Question(text: "How many chambers does a human heart have?",
                 options: ["2", "3", "4", "5"],
                 correctAnswer: "4"),
        Question(text: "What is the hardest natural substance on Earth?",
                 options: ["Gold", "Iron", "Diamond", "Quartz"],
                 correctAnswer: "Diamond"),
        Question(text: "What planet is known as the Red Planet?",
                 options: ["Venus", "Mars", "Jupiter", "Saturn"],
                 correctAnswer: "Mars"),
        Question(text: "How many chromosomes do humans have?",
                 options: ["23", "44", "46", "48"],
                 correctAnswer: "46"),
        Question(text: "What is the powerhouse of the cell?",
                 options: ["Nucleus", "Ribosome", "Mitochondria", "Cytoplasm"],
                 correctAnswer: "Mitochondria"),
        Question(text: "What is the most abundant gas in Earth's atmosphere?",
                 options: ["Oxygen", "Carbon Dioxide", "Hydrogen", "Nitrogen"],
                 correctAnswer: "Nitrogen"),
        Question(text: "How many teeth does an adult human have?",
                 options: ["28", "30", "32", "34"],
                 correctAnswer: "32"),
        Question(text: "What is the closest star to Earth?",
                 options: ["Sirius", "The Sun", "Proxima Centauri", "Betelgeuse"],
                 correctAnswer: "The Sun"),
        Question(text: "What organ produces insulin?",
                 options: ["Liver", "Kidney", "Heart", "Pancreas"],
                 correctAnswer: "Pancreas"),
    ],
        // Set 3 - History
        [
            Question(text: "Who was the first President of the United States?",
                     options: ["John Adams", "Thomas Jefferson", "George Washington", "Benjamin Franklin"],
                     correctAnswer: "George Washington"),
            Question(text: "In what year did the Titanic sink?",
                     options: ["1910", "1912", "1914", "1916"],
                     correctAnswer: "1912"),
            Question(text: "Which empire was Julius Caesar a part of?",
                     options: ["Greek", "Ottoman", "Roman", "Byzantine"],
                     correctAnswer: "Roman"),
            Question(text: "What year did the Berlin Wall fall?",
                     options: ["1987", "1988", "1989", "1990"],
                     correctAnswer: "1989"),
            Question(text: "Who painted the Mona Lisa?",
                     options: ["Michelangelo", "Raphael", "Leonardo da Vinci", "Donatello"],
                     correctAnswer: "Leonardo da Vinci"),
            Question(text: "Which country was the first to give women the right to vote?",
                     options: ["USA", "UK", "New Zealand", "France"],
                     correctAnswer: "New Zealand"),
            Question(text: "How long did the Hundred Years War last?",
                     options: ["100 years", "116 years", "99 years", "150 years"],
                     correctAnswer: "116 years"),
            Question(text: "Who was the first man to walk on the moon?",
                     options: ["Buzz Aldrin", "Yuri Gagarin", "Neil Armstrong", "John Glenn"],
                     correctAnswer: "Neil Armstrong"),
            Question(text: "Which country did Napoleon Bonaparte come from?",
                     options: ["France", "Corsica", "Italy", "Spain"],
                     correctAnswer: "Corsica"),
            Question(text: "What ancient wonder was located in Alexandria?",
                     options: ["Colossus", "Hanging Gardens", "Great Lighthouse", "Statue of Zeus"],
                     correctAnswer: "Great Lighthouse"),
        ],

        // Set 4 - Geography
        [
            Question(text: "What is the longest river in the world?",
                     options: ["Amazon", "Yangtze", "Mississippi", "Nile"],
                     correctAnswer: "Nile"),
            Question(text: "Which country has the most natural lakes?",
                     options: ["Russia", "Canada", "USA", "Brazil"],
                     correctAnswer: "Canada"),
            Question(text: "What is the smallest country in the world?",
                     options: ["Monaco", "San Marino", "Vatican City", "Liechtenstein"],
                     correctAnswer: "Vatican City"),
            Question(text: "Which desert is the largest in the world?",
                     options: ["Sahara", "Gobi", "Arabian", "Antarctic"],
                     correctAnswer: "Antarctic"),
            Question(text: "What is the capital of Canada?",
                     options: ["Toronto", "Vancouver", "Montreal", "Ottawa"],
                     correctAnswer: "Ottawa"),
            Question(text: "Which mountain range separates Europe from Asia?",
                     options: ["Alps", "Himalayas", "Ural Mountains", "Caucasus"],
                     correctAnswer: "Ural Mountains"),
            Question(text: "What is the largest country by area?",
                     options: ["China", "USA", "Canada", "Russia"],
                     correctAnswer: "Russia"),
            Question(text: "Which ocean is the smallest?",
                     options: ["Atlantic", "Indian", "Arctic", "Southern"],
                     correctAnswer: "Arctic"),
            Question(text: "What is the capital of Brazil?",
                     options: ["Rio de Janeiro", "Sao Paulo", "Brasilia", "Salvador"],
                     correctAnswer: "Brasilia"),
            Question(text: "Which African country has the largest population?",
                     options: ["Egypt", "South Africa", "Nigeria", "Ethiopia"],
                     correctAnswer: "Nigeria"),
        ],

        // Set 5 - Sports
        [
            Question(text: "How many players are on a basketball team on the court?",
                     options: ["4", "5", "6", "7"],
                     correctAnswer: "5"),
            Question(text: "Which country has won the most FIFA World Cups?",
                     options: ["Germany", "Argentina", "Italy", "Brazil"],
                     correctAnswer: "Brazil"),
            Question(text: "How many holes are in a standard round of golf?",
                     options: ["9", "12", "16", "18"],
                     correctAnswer: "18"),
            Question(text: "What sport is played at Wimbledon?",
                     options: ["Badminton", "Squash", "Tennis", "Cricket"],
                     correctAnswer: "Tennis"),
            Question(text: "How long is a marathon in miles?",
                     options: ["24.2", "25.5", "26.2", "27.0"],
                     correctAnswer: "26.2"),
            Question(text: "Which country invented basketball?",
                     options: ["USA", "Canada", "UK", "Australia"],
                     correctAnswer: "Canada"),
            Question(text: "How many points is a touchdown worth in American football?",
                     options: ["4", "5", "6", "7"],
                     correctAnswer: "6"),
            Question(text: "What is the diameter of a basketball hoop in inches?",
                     options: ["16", "18", "20", "22"],
                     correctAnswer: "18"),
            Question(text: "In which sport would you perform a Fosbury Flop?",
                     options: ["Pole Vault", "Long Jump", "High Jump", "Triple Jump"],
                     correctAnswer: "High Jump"),
            Question(text: "How many grand slams are there in tennis?",
                     options: ["2", "3", "4", "5"],
                     correctAnswer: "4"),
        ],

        // Set 6 - Movies & TV
        [
            Question(text: "How many Infinity Stones are there in the Marvel universe?",
                     options: ["4", "5", "6", "7"],
                     correctAnswer: "6"),
            Question(text: "What year was the first iPhone released?",
                     options: ["2005", "2006", "2007", "2008"],
                     correctAnswer: "2007"),
            Question(text: "Which streaming service produced Stranger Things?",
                     options: ["HBO", "Amazon", "Disney+", "Netflix"],
                     correctAnswer: "Netflix"),
            Question(text: "What is the highest grossing movie of all time?",
                     options: ["Titanic", "Avengers Endgame", "Avatar", "Star Wars"],
                     correctAnswer: "Avatar"),
            Question(text: "How many seasons does Game of Thrones have?",
                     options: ["6", "7", "8", "9"],
                     correctAnswer: "8"),
            Question(text: "Which actor played Iron Man in the MCU?",
                     options: ["Chris Evans", "Mark Ruffalo", "Robert Downey Jr", "Chris Hemsworth"],
                     correctAnswer: "Robert Downey Jr"),
            Question(text: "What language is spoken in the show Money Heist?",
                     options: ["Portuguese", "Italian", "French", "Spanish"],
                     correctAnswer: "Spanish"),
            Question(text: "Which movie features the quote 'I see dead people'?",
                     options: ["The Shining", "Get Out", "The Sixth Sense", "Us"],
                     correctAnswer: "The Sixth Sense"),
            Question(text: "How many episodes are in the first season of Breaking Bad?",
                     options: ["5", "7", "9", "13"],
                     correctAnswer: "7"),
            Question(text: "What studio made the Toy Story films?",
                     options: ["DreamWorks", "Disney", "Pixar", "Universal"],
                     correctAnswer: "Pixar"),
        ],

        // Set 7 - Food & Drink
        [
            Question(text: "Which country does sushi originally come from?",
                     options: ["China", "Korea", "Thailand", "Japan"],
                     correctAnswer: "Japan"),
            Question(text: "What is the main ingredient in guacamole?",
                     options: ["Tomato", "Avocado", "Lime", "Onion"],
                     correctAnswer: "Avocado"),
            Question(text: "Which country produces the most coffee in the world?",
                     options: ["Colombia", "Vietnam", "Ethiopia", "Brazil"],
                     correctAnswer: "Brazil"),
            Question(text: "What type of pastry is a croissant?",
                     options: ["Choux", "Shortcrust", "Filo", "Puff"],
                     correctAnswer: "Puff"),
            Question(text: "Which fruit has the most varieties?",
                     options: ["Apple", "Banana", "Mango", "Orange"],
                     correctAnswer: "Apple"),
            Question(text: "What is the spiciest pepper in the world?",
                     options: ["Ghost Pepper", "Habanero", "Carolina Reaper", "Scotch Bonnet"],
                     correctAnswer: "Carolina Reaper"),
            Question(text: "Which country invented pizza?",
                     options: ["USA", "Greece", "France", "Italy"],
                     correctAnswer: "Italy"),
            Question(text: "What is tofu made from?",
                     options: ["Rice", "Chickpeas", "Soybeans", "Almonds"],
                     correctAnswer: "Soybeans"),
            Question(text: "Which nut is used to make marzipan?",
                     options: ["Walnut", "Hazelnut", "Cashew", "Almond"],
                     correctAnswer: "Almond"),
            Question(text: "What country does cheddar cheese originally come from?",
                     options: ["France", "USA", "England", "Netherlands"],
                     correctAnswer: "England"),
        ],

        // Set 8 - Technology
        [
            Question(text: "What does CPU stand for?",
                     options: ["Central Processing Unit", "Computer Personal Unit", "Central Program Utility", "Core Processing Unit"],
                     correctAnswer: "Central Processing Unit"),
            Question(text: "Who co-founded Apple with Steve Jobs?",
                     options: ["Bill Gates", "Steve Wozniak", "Elon Musk", "Mark Zuckerberg"],
                     correctAnswer: "Steve Wozniak"),
            Question(text: "What programming language was Swift created to replace?",
                     options: ["C++", "Java", "Objective-C", "Python"],
                     correctAnswer: "Objective-C"),
            Question(text: "What does HTML stand for?",
                     options: ["Hyper Text Markup Language", "High Tech Modern Language", "Hyper Transfer Markup Logic", "Home Tool Markup Language"],
                     correctAnswer: "Hyper Text Markup Language"),
            Question(text: "Which company made the first commercial smartphone?",
                     options: ["Apple", "Nokia", "IBM", "Blackberry"],
                     correctAnswer: "IBM"),
            Question(text: "What does RAM stand for?",
                     options: ["Random Access Memory", "Read Access Module", "Rapid Array Memory", "Runtime Access Mode"],
                     correctAnswer: "Random Access Memory"),
            Question(text: "In what year was Google founded?",
                     options: ["1996", "1997", "1998", "1999"],
                     correctAnswer: "1998"),
            Question(text: "What programming language is primarily used for iOS apps?",
                     options: ["Java", "Kotlin", "Swift", "Python"],
                     correctAnswer: "Swift"),
            Question(text: "What does Wi-Fi stand for?",
                     options: ["Wireless Fidelity", "Wide Frequency", "Wireless Frequency Interface", "It stands for nothing"],
                     correctAnswer: "Wireless Fidelity"),
            Question(text: "Which company owns Instagram?",
                     options: ["Google", "Twitter", "Meta", "Apple"],
                     correctAnswer: "Meta"),
        ],

        // Set 9 - Music
        [
            Question(text: "How many strings does a standard guitar have?",
                     options: ["4", "5", "6", "7"],
                     correctAnswer: "6"),
            Question(text: "Which band performed the most at Glastonbury festival?",
                     options: ["The Rolling Stones", "Coldplay", "U2", "David Bowie"],
                     correctAnswer: "Coldplay"),
            Question(text: "What is the fastest selling album of all time?",
                     options: ["Thriller", "Back in Black", "Taylor Swift's 1989", "Adele's 25"],
                     correctAnswer: "Adele's 25"),
            Question(text: "How many keys does a standard piano have?",
                     options: ["76", "82", "88", "92"],
                     correctAnswer: "88"),
            Question(text: "Which country does the band ABBA come from?",
                     options: ["Norway", "Denmark", "Finland", "Sweden"],
                     correctAnswer: "Sweden"),
            Question(text: "What instrument does a percussionist play?",
                     options: ["Brass", "Strings", "Woodwind", "Drums"],
                     correctAnswer: "Drums"),
            Question(text: "What does BPM stand for in music?",
                     options: ["Bass Per Minute", "Beats Per Measure", "Beats Per Minute", "Bass Per Measure"],
                     correctAnswer: "Beats Per Minute"),
            Question(text: "Which musician is known as the King of Pop?",
                     options: ["Elvis Presley", "Prince", "Michael Jackson", "David Bowie"],
                     correctAnswer: "Michael Jackson"),
            Question(text: "How many musicians are in a quartet?",
                     options: ["3", "4", "5", "6"],
                     correctAnswer: "4"),
            Question(text: "What note does a standard guitar string A tune to in Hz?",
                     options: ["220 Hz", "440 Hz", "880 Hz", "110 Hz"],
                     correctAnswer: "440 Hz"),
        ],

        // Set 10 - Space
        [
            Question(text: "How long does it take light to travel from the Sun to Earth?",
                     options: ["4 minutes", "8 minutes", "12 minutes", "16 minutes"],
                     correctAnswer: "8 minutes"),
            Question(text: "What is the name of the galaxy we live in?",
                     options: ["Andromeda", "Triangulum", "Milky Way", "Sombrero"],
                     correctAnswer: "Milky Way"),
            Question(text: "What is the hottest planet in our solar system?",
                     options: ["Mercury", "Mars", "Jupiter", "Venus"],
                     correctAnswer: "Venus"),
            Question(text: "How many moons does Mars have?",
                     options: ["0", "1", "2", "3"],
                     correctAnswer: "2"),
            Question(text: "What year did the first human travel to space?",
                     options: ["1959", "1960", "1961", "1962"],
                     correctAnswer: "1961"),
            Question(text: "What is a light year a measure of?",
                     options: ["Time", "Speed", "Distance", "Brightness"],
                     correctAnswer: "Distance"),
            Question(text: "Which space telescope was launched in 1990?",
                     options: ["James Webb", "Spitzer", "Chandra", "Hubble"],
                     correctAnswer: "Hubble"),
            Question(text: "What is the largest volcano in our solar system?",
                     options: ["Mauna Kea", "Mount Olympus", "Olympus Mons", "Tharsis"],
                     correctAnswer: "Olympus Mons"),
            Question(text: "How many Earth days does it take Mars to orbit the Sun?",
                     options: ["487", "587", "687", "787"],
                     correctAnswer: "687"),
            Question(text: "What percentage of our solar system's mass does the Sun make up?",
                     options: ["89%", "95%", "97%", "99%"],
                     correctAnswer: "99%"),
        ],
    ]
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var quizFinished = false
    @State private var gameStarted = false
    @State private var shuffledQuestions: [Question] = []
    @State private var usedSetIndexes: [Int] = []
    @State private var currentSetIndex: Int = 0
    
    func handleAnswer(_ selectedIndex: Int) {
        selectedAnswer = selectedIndex
        if shuffledQuestions[currentIndex].options[selectedIndex] == shuffledQuestions[currentIndex].correctAnswer {
            score += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { selectedAnswer = nil
            if currentIndex + 1 < questionSets[currentSetIndex].count {
                currentIndex += 1
            } else {
                quizFinished = true
            }
        }
    }
    func buttonColor(for index: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Color.white.opacity(0.2) //no answer yet, default color
        }
        if shuffledQuestions[currentIndex].options[index] == shuffledQuestions[currentIndex].correctAnswer {
            return Color.green.opacity(0.85) // always show correct in green
        }
        if index == selected {
            return Color.red.opacity(0.75) //wrong choice turns red
        }
        return Color.white.opacity(0.1) // other buttons go dim
    }
    func restartQuiz() {
        currentIndex = 0
        score = 0
        selectedAnswer = nil
        quizFinished = false
        gameStarted = false
        let picked = pickRandomSet()
        shuffledQuestions = questionSets[picked].map { question in
                Question(text: question.text,
                         options: question.options.shuffled(),
                         correctAnswer: question.correctAnswer)
        }
    }
    func pickRandomSet() -> Int {
        let available = (0..<questionSets.count).filter { !usedSetIndexes.contains($0) }
        if usedSetIndexes.count == questionSets.count {
            usedSetIndexes = []
        }
        if let picked = available.randomElement() {
            currentSetIndex = picked
            usedSetIndexes.append(picked)
            return picked
        }
        return 0
    }
    var body: some View {
        if !gameStarted {
            ZStack {
                Color.indigo.ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("🧠")
                        .font(.system(size: 80))
                    Text("Quiz App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Test your knowledge!")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.8))
                            Button("Start Quiz") {
                                gameStarted = true
                            }
                            .font(.headline)
                            .foregroundColor(.indigo)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
            .onAppear {
                let picked = pickRandomSet()
                shuffledQuestions = questionSets[picked].map { question in
                Question(text: question.text,
                         options: question.options.shuffled(),
                         correctAnswer: question.correctAnswer)
            }
            }
                } else if quizFinished {
            ZStack {
                Color.indigo.ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("🏆")
                        .font(.system(size: 80))
                    Text("Quiz Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("You scored \(score) out of \(questionSets[currentSetIndex].count)")
                        .font(.title2)
                        .foregroundColor(.white)
                    Button("Play Again") {
                        restartQuiz()
                    }
                    .font(.headline)
                    .foregroundColor(.indigo)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
        }else{
            ZStack {
                Color.indigo.ignoresSafeArea()
                // Counter pinned to top right
                VStack {
                    HStack {
                        Spacer()
                        Text("Question \(currentIndex + 1) of \(questionSets[currentSetIndex].count)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.75))
                            .padding()
                    }
                    Spacer()
                }
                VStack(spacing: 24) {
                    Text(shuffledQuestions[currentIndex].text)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    ForEach(0..<shuffledQuestions[currentIndex].options.count, id: \.self) { i in
                        Button(action: {
                            handleAnswer(i)
                        }) {
                            Text(shuffledQuestions[currentIndex].options[i])
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(buttonColor(for: i))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                }
                .padding()
            }
        }
        }
    }


#Preview {
    ContentView()
}

