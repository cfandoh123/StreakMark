import SwiftUI

// Model for each day
struct HabitDay: Identifiable {
    var id: Date { date }
    var date: Date
    var isDone: Bool
}

// ViewModel to manage habit days and streak logic
class HabitViewModel: ObservableObject {
    @Published var days: [HabitDay] = []
    
    init() {
        generateDays()
    }
    
    // Generate days for the current month
    func generateDays() {
        let calendar = Calendar.current
        let today = Date()
        guard let range = calendar.range(of: .day, in: .month, for: today),
              let monthComponents = calendar.dateComponents([.year, .month], from: today) as DateComponents? else {
            return
        }
        
        days = range.compactMap { day -> HabitDay? in
            var comps = monthComponents
            comps.day = day
            if let date = calendar.date(from: comps) {
                return HabitDay(date: date, isDone: false)
            }
            return nil
        }
    }
    
    // Toggle the "done" state for a given day
    func toggleDone(for day: HabitDay) {
        if let index = days.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: day.date) }) {
            days[index].isDone.toggle()
        }
    }
    
    // Compute current streak: consecutive days (including today) marked as done
    func currentStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = Date()
        
        // Loop backwards day-by-day until a day is not marked done
        while true {
            if let habitDay = days.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
                if habitDay.isDone {
                    streak += 1
                } else {
                    break
                }
            } else {
                // If the day is not part of our current month, we stop the count
                break
            }
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: date) else {
                break
            }
            date = previousDate
        }
        return streak
    }
}

struct ContentView: View {
    @ObservedObject var viewModel = HabitViewModel()
    // Define grid columns (adjust minimum size as needed)
    let columns = [GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        VStack {
            Text("Habit Tracker")
                .font(.largeTitle)
                .padding(.top)
            
            Text("Current Streak: \(viewModel.currentStreak())")
                .font(.headline)
                .padding(.vertical)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(viewModel.days) { day in
                        let formatter = DateFormatter()
                        formatter.dateFormat = "d"
                        let dayString = formatter.string(from: day.date)
                        
                        Text(dayString)
                            .frame(width: 40, height: 40)
                            .background(day.isDone ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .onTapGesture {
                                viewModel.toggleDone(for: day)
                            }
                    }
                }
                .padding()
            }
            Spacer()
        }
    }
}

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
