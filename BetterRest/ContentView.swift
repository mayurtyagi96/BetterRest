//
//  ContentView.swift
//  BetterRest
//
//  Created by Mayur on 14/07/24.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeUpTime
    @State private var sleepAmount  = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showinAlert = false
    
    static var defaultWakeUpTime: Date{
        var components = DateComponents(hour: 7, minute: 0)
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form{
                VStack(alignment: .leading, spacing: 2){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    DatePicker("please enter the time", selection: $wakeUp, displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                }
                VStack(alignment: .leading, spacing: 2){
                    Text("Desired amoun to sleep")
                        .font(.headline)
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                VStack(alignment: .leading, spacing: 2){
                    Text("Daily coffee intake")
                        .font(.headline)
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 0...20)
                }
            }
            .navigationTitle("BetterRest")
            .toolbar {
                Button("Calculate", action: calculateBadTime)
            }
            .alert(alertTitle, isPresented: $showinAlert) {
                Button("OK") {}
            } message: {
                Text(alertMsg)
            }
        }
    }
    func calculateBadTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bed time is..."
            alertMsg = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch{
            alertTitle = "Error"
            alertMsg = "Some problem"
        }
        showinAlert = true
    }
}

#Preview {
    ContentView()
}
