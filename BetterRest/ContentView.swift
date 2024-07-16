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
    @State private var coffeeAmount = 0
    @State private var alertTitle = ""
    @State private var alertMsg = ""
    @State private var showinAlert = false
    
    static var defaultWakeUpTime: Date{
        let components = DateComponents(hour: 7, minute: 0)
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form{
                
                Section(header: Text("Current recomended bedtime").font(.headline)){
                    Text("\(getFinalUserMsg())")
                        .font(.headline)
                }
                
                Section(header: Text("When do you want to wake up?").font(.headline)){
                        DatePicker("please enter the time", selection: $wakeUp, displayedComponents: [.hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.wheel)
                }
                
                Section(header: Text("Desired amount to sleep").font(.headline)){
                        Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section(header: Text("Daily coffee intake").font(.headline)){
                        Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                            ForEach(0..<21){index in
                                Text("\(index)")
                            }
                        }
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showinAlert) {
                Button("OK") {}
            } message: {
                Text("Your ideal bed time is..." + alertMsg)
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
    
    func getFinalUserMsg() -> String {
        let config = MLModelConfiguration()
        let model = try? SleepCalculator(configuration: config)
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        let userMsg : String
        
        do {
            let prediction = try model?.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - (prediction?.actualSleep ?? 0)

            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            userMsg = formatter.string(from: sleepTime)
        } catch {
            userMsg = "Error with calculation"
        }
        
        return userMsg
    }
}

#Preview {
    ContentView()
}
