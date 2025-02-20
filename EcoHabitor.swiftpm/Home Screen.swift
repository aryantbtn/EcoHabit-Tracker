//
//  File.swift
//  EcoHabitor
//
//  Created by ARYAN SINGHAL on 10/02/25.
//

import SwiftUI


struct MainTabView: View {
    
    init() {
        // Set the navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.green]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        // Set the back button color
        UINavigationBar.appearance().tintColor = .green
        }
    
    @StateObject private var historyViewModel = HistoryViewModel()
    var body: some View {
        TabView {
            HomeScreen(historyViewModel: historyViewModel).tabItem {
                Label("Home", systemImage: "house.fill")
            }
            
            InfoView()
                .tabItem {
                    Label("Info", systemImage: "info.circle.fill")
            }
            
            HistoryScreen(historyViewModel: historyViewModel)
                .tabItem {
                    Label("History", systemImage: "clock.fill")
            }
        }
    }
}


struct HomeScreen: View {
    
    @ObservedObject var historyViewModel: HistoryViewModel
    
    // State variables for user inputs
    @State private var wakeUpEarly: Bool = false
    @State private var waterIntake: Double = 0.0
    @State private var stepsWalkedToday: Int = 0
    
    @State private var avoidedCar: Bool = false
    @State private var transportMode: String = "Public Transport"
    let transportOptions = [
        "bus.fill",       // Public Transport
        "bolt.car",  // Electric Vehicle
        "bicycle",        // Cycle
        "figure.walk"     // Walking
    ]
    @State private var publicTransport: Bool = false
    @State private var cycleTime: Int = 0
    @State private var cycleDistance: Double = 0.0
    @State private var walkTime: Int = 0
    @State private var stepsTaken: Int = 0
    
    @State private var singleUsePlasticAvoided: Bool = false
    @State private var bottlesRecycled: Int = 0
    @State private var reusableItems: Int = 0
    
    @State private var isSmoker: Bool = false
    @State private var cigarettesSmoked: Int = 0
    
    @State private var isVegan: Bool = false
    @State private var vegMeals: Int = 0
    @State private var nonVegMeals: Int = 0
    @State private var showerTimeReduced: Int = 0
    @State private var electricitySaved: Double = 0.0
    
    @State private var devicesTurnedOff: Int = 0
    @State private var reducedACUsage: Bool = false
    @State private var acHoursReduced: Int = 0 // Hours AC was reduced
    

    // State variable for carbon reduction result
    @State private var carbonReduction: Double = 0.0

    @State private var showInfoModal: Bool = false
    
    @State private var isInfoPresented = false
    
    private var hasUserInput: Bool {
        wakeUpEarly ||
        waterIntake > 0 ||
        stepsWalkedToday > 0 ||
        avoidedCar ||
        singleUsePlasticAvoided ||
        bottlesRecycled > 0 ||
        reusableItems > 0 ||
        (isSmoker && cigarettesSmoked >= 0) ||
        (isVegan && vegMeals > 0) ||
        showerTimeReduced > 0 ||
        devicesTurnedOff > 0 ||
        (reducedACUsage && acHoursReduced > 0)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 17) {
                        Text("Enter your daily habits to calculate your carbon emission reductions.")
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .blue.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                            .background(RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(colors: [.white, Color.green.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .shadow(color: .green.opacity(0.2), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                            .animation(.easeInOut(duration: 0.5), value: showInfoModal)
                        }
                        .padding(.top, 10)
                
                        // MARK:- Wake Up Early Toggle
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "sunrise.fill")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                Toggle("Did you wake up early today?", isOn: $wakeUpEarly)
                                    .font(.headline)
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                
                    // MARK:- Water Intake Slider
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Water Intake (liters)")
                                .font(.headline)
                        }
                        Text("\(String(format: "%.1f", waterIntake)) L")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Slider(value: $waterIntake, in: 0...5, step: 0.1)
                            .accentColor(.green)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                    // Walking Stepper
                    CustomStepperView(
                        icon: "figure.walk",
                        iconColor: .green,
                        title: "Steps Walked Today",
                        value: $stepsWalkedToday,
                        range: 0...30000,
                        step: 1000
                    )
                
                    // Avoid Car Usage
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "car.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                            Toggle("Did you avoid using a car today?", isOn: $avoidedCar)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                    if avoidedCar {
                        VStack(alignment: .leading) {
                            Text("Which mode of transport did you use?")
                                .font(.headline)
                            Picker("Transport Mode", selection: $transportMode) {
                                ForEach(transportOptions, id: \.self) { option in
                                    Text(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)

                        // Cycling Inputs
                        if transportMode == "Cycle" {
                            VStack(alignment: .leading) {
                                Text("Time Cycled (minutes): \(cycleTime)")
                                    .font(.headline)

                                Stepper(value: $cycleTime, in: 0...180, step: 5) {
                                    Text("\(cycleTime) min")
                                }
                                .padding(.bottom, 10)

                                Text("Distance Cycled (miles): \(String(format: "%.1f", cycleDistance))")
                                    .font(.headline)

                                Slider(value: $cycleDistance, in: 0...50, step: 0.5)
                                    .accentColor(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        
                        // Walking Inputs
                        if transportMode == "Walking" {
                            VStack(alignment: .leading) {
                                Text("Time Walked (minutes): \(walkTime)")
                                    .font(.headline)
                                Stepper(value: $walkTime, in: 0...180, step: 5) {
                                    Text("\(walkTime) min")
                                }
                                .padding(.bottom, 10)

                                Text("Steps Walked: \(stepsTaken)")
                                    .font(.headline)

                                Stepper(value: $stepsTaken, in: 0...30000, step: 1000) {
                                    Text("\(stepsTaken) steps")
                                }
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                
                    // MARK:- Avoid Single-Use Plastic Toggle
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                            Toggle("Did you avoid single-use plastics today?", isOn: $singleUsePlasticAvoided)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                    // Bottles Recycled Stepper
                    CustomStepperView(
                        icon: "arrow.3.trianglepath",
                        iconColor: .blue,
                        title: "Bottles Recycled Today",
                        value: $bottlesRecycled,
                        range: 1000...20000,
                        step: 1000
                    )
                
                    // Reusable Product Used
                    CustomStepperView(
                        icon: "leaf.fill",
                        iconColor: .green,
                        title: "Reusable Items Used",
                        value: $reusableItems,
                        range: 0...10,
                        step: 1
                    )
                
                    // Smoking Stepper Controls
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "smoke.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Toggle("Do you smoke?", isOn: $isSmoker)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                                        
                    if isSmoker {
                        CustomStepperView(
                            icon: "smoke.fill",
                            iconColor: .red,
                            title: "Cigarettes Smoked Today",
                            value: $cigarettesSmoked,
                            range: 0...40,
                            step: 1
                        )
                    }
                
                    // Vegetarian or not
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "leaf.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            Toggle("Are you vegan?", isOn: $isVegan)
                                .font(.headline)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                    // Vegetarian Meals (Enabled only if Vegan)
                    if isVegan {
                        CustomStepperView(
                            icon: "leaf.fill",
                            iconColor: .green,
                            title: "Vegetarian Meals Eaten",
                            value: $vegMeals,
                            range: 0...10,
                            step: 1
                        )
                    }
                
                    // Devices Power Energies
                    CustomStepperView(
                        icon: "power",
                        iconColor: .orange,
                        title: "Unused Devices Turned Off",
                        value: $devicesTurnedOff,
                        range: 0...100,
                        step: 1
                    )
                                        
                    // Shower Time with Icon
                    CustomStepperView(
                        icon: "shower.fill",
                        iconColor: .blue,
                        title: "Minutes Reduced in Shower",
                        value: $showerTimeReduced,
                        range: 0...10,
                        step: 1
                    )
                                        
                    // AC Usage with Icon
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "thermometer.sun.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                            Toggle("Did you reduce AC usage today?", isOn: $reducedACUsage)
                                .font(.headline)
                        }
                        
                        if reducedACUsage {
                            CustomStepperView(
                                icon: "thermometer.sun.fill",
                                iconColor: .orange,
                                title: "Hours of AC Usage Reduced",
                                value: $acHoursReduced,
                                range: 0...24,
                                step: 1
                            )
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Calculate Button
                    Button(action: {
                        
                        calculateCarbonReduction()
                        historyViewModel.addHistoryItem(carbonReduction: carbonReduction)
                    }) {
                        Text("Calculate Carbon Reduction")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(!hasUserInput)
                    .padding(.horizontal)
                    .opacity(hasUserInput ? 1.0 : 0.7)
                    
                    // Result Display
                    Text("Your Total Carbon Reduction:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                        
                    Text("\(String(format: "%.2f", carbonReduction)) kg CO₂")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .padding()
                        
                    Spacer()
                }
                    
            }
            .navigationTitle("Daily Habit Tracker")
            .navigationBarTitleDisplayMode(.large)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            showInfoModal = true
                        }
                    }) {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationViewStyle(.stack)
            .sheet(isPresented: $showInfoModal) {
                InfoView()
            }
        }
    }

    // Function to calculate carbon reduction
    private func calculateCarbonReduction() {
        var reduction = 0.0

        // Add values for each habit
        if wakeUpEarly {
            reduction += 0.5 // Example: Waking up early saves 0.5 kg CO₂
        }

        reduction += waterIntake * 0.2 // 1L of water saved = 0.2 kg CO₂ reduction
        reduction += Double(stepsWalkedToday / 1000) * 0.1 // 1000 steps walked = 0.1 kg CO₂ saved
    
        if avoidedCar {
            switch transportMode {
                
            case "Public Transport":
                reduction += 2.0 // 🚆 Public transport saves ~2.0 kg CO₂ vs. driving

            case "Electric Vehicle":
                reduction += 1.0 // ⚡ EVs reduce emissions but still have battery-related CO₂

            case "Cycle":
                let cycleEmissionsSaved = (cycleDistance * 0.411) // 🚴 1 mile cycling = 411g CO₂ saved
                let timeFactor = Double(cycleTime) * 0.05 // 🚴 Cycling 10 min saves 0.5 kg CO₂
                reduction += max(cycleEmissionsSaved, timeFactor) // Take max of time or distance-based calc
            
            case "Walking":
                let walkEmissionsSaved = Double(stepsTaken / 1000) * 0.1 // 🚶 1000 steps = 0.1 kg CO₂ saved
                let timeFactor = Double(walkTime) * 0.06 // 🚶 Walking 10 min saves 0.6 kg CO₂
                reduction += max(walkEmissionsSaved, timeFactor)

            default:
                break
            }
        }
    
        if publicTransport {
            reduction += 2.0 // Example: Using public transport saves 2.0 kg CO₂
        }

        if singleUsePlasticAvoided {
            reduction += 1.5 // Example: Avoiding single-use plastics saves 1.5 kg CO₂
        }

        reduction += electricitySaved * 0.7 // Example: Every kWh saved = 0.7 kg CO₂

        reduction += Double(bottlesRecycled) * 0.05
    
        if reducedACUsage {
            reduction += Double(acHoursReduced) * 0.8 // Example: Each hour of AC reduction saves 0.8 kg CO₂
        }
    
        if wakeUpEarly {
            reduction += 0.5 // Example: Waking up early saves 0.5 kg CO₂ by reducing electricity use
        }

        if publicTransport {
            reduction += 2.0 // Using public transport saves 2.0 kg CO₂ vs. driving
        }

        if singleUsePlasticAvoided {
            reduction += 1.5 // Avoiding single-use plastics saves 1.5 kg CO₂
        }

        reduction += Double(bottlesRecycled) * 0.05 // 1 bottle recycled = 0.05 kg CO₂ saved
            
        if reducedACUsage {
            reduction += Double(acHoursReduced) * 0.8 // 1 hour of AC reduction saves 0.8 kg CO₂
        }
    
        // Smoking Impact Calculation
        if isSmoker {
            let reductionPerCigarette = 0.02 // Example: Each cigarette avoided saves 0.02 kg CO₂
            let maxDailySmokes = 20 // Assume max smoking habit is 20 cigarettes per day
            let avoidedCigarettes = maxDailySmokes - cigarettesSmoked
            if avoidedCigarettes > 0 {
                reduction += Double(avoidedCigarettes) * reductionPerCigarette
            }
        }
    
        if isVegan {
            reduction += Double(vegMeals) * 2.0 // 1 vegetarian meal instead of meat = 2 kg CO₂ saved
        }
        // Update the state to reflect the calculated result
        carbonReduction = reduction
    }
}
