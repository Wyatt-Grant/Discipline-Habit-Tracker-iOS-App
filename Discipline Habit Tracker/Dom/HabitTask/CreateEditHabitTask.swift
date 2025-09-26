//
//  CreateNewTask.swift
//  Discipline Habit Tracker
//
//  Created by Wyatt Grant on 2023-10-21.
//

import EventKit
import SimpleToast
import SwiftUI

struct CreateEditHabitTask: View {
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.presentationMode) var presentation

  let nth = ["First", "Second", "Third", "Fourth", "Fifth", "Last"]
  let weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  let months = [
    "January", "February", "March", "April", "May", "June", "July", "August", "September",
    "October", "November", "December",
  ]
  let intToEKRecurrenceDayOfWeekMap: [Int: EKRecurrenceDayOfWeek] = [
    1: EKRecurrenceDayOfWeek(.sunday),
    2: EKRecurrenceDayOfWeek(.monday),
    3: EKRecurrenceDayOfWeek(.tuesday),
    4: EKRecurrenceDayOfWeek(.wednesday),
    5: EKRecurrenceDayOfWeek(.thursday),
    6: EKRecurrenceDayOfWeek(.friday),
    7: EKRecurrenceDayOfWeek(.saturday),
  ]

  @Binding var habitTask: HabitTask
  @State private var dynamic = emptyDynamic()
  public var editMode = false
  @State var hasLoadedTaskData = false

  @State private var name = ""
  @State private var desc = ""
  @State private var value = 1
  @State private var max = 1
  @State private var target = 1
  @State private var rrule = ""
  @State private var remove_points_on_failure = false
  @State private var remind = false
  @State private var remindTime = Date()
  @State private var restrict = false
  @State private var restrictBefore = false
  @State private var restrictTime = Date()

  @State private var startDate: Date = Date()
  @State private var endDate: Date = Date()
  @State private var limitedTime: Int = 0
  @State private var byType = "date"

  @State private var frequency: EKRecurrenceFrequency = .daily
  @State private var interval: Int = 1
  @State private var selectedDates: Set<NSNumber> = []
  @State private var selectedDays: Set<EKRecurrenceDayOfWeek> = []
  @State private var selectedMonths: Set<NSNumber> = []
  @State private var occurrences: Int = 1
  @State private var showToast = false

  @State private var waiting = false

  var body: some View {
    ZStack {
      Color.clear
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
          self.endTextEditing()
        }
      VStack {
        Form {
          Section(header: Text("Basic Details")) {
            TextField("Name", text: $name)
              .padding()
              .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
              .cornerRadius(10)
            TextField("Description", text: $desc, axis: .vertical)
              .padding()
              .lineLimit(5, reservesSpace: true)
              .background(colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.05))
              .cornerRadius(10)
            Stepper(
              value: $value, in: 0...99,
              label: {
                Text("\(value) \(value == 1 ? "point" : "points")")
              })
            Stepper(
              value: $target, in: 0...99,
              label: {
                Text("Perform \(target) \(target == 1 ? "time" : "times")")
              }
            )
            .onChange(
              of: target,
              { oldValue, newValue in
                if target > max {
                  max = target
                }
              })
            Stepper(
              value: $max, in: target...99,
              label: {
                Text("At most \(max) \(max == 1 ? "time" : "times")")
              })
            Toggle("Remove Points on Failure", isOn: $remove_points_on_failure)
            Toggle("Remind", isOn: $remind)
            if remind {
              DatePicker(
                "time to remind", selection: $remindTime, displayedComponents: .hourAndMinute
              )
              .datePickerStyle(WheelDatePickerStyle())
              .labelsHidden()
            }
          }

          // time
          Section(header: Text("Time Restrictions")) {
            Toggle("Restrict Time", isOn: $restrict)
            if restrict {
              Toggle(
                restrictBefore ? "Can only be done before" : "Can only be done after",
                isOn: $restrictBefore)
              DatePicker(
                "", selection: $restrictTime, displayedComponents: .hourAndMinute
              )
              .datePickerStyle(WheelDatePickerStyle())
              .labelsHidden()
            }
          }

          // date
          Section(header: Text("Repeat for")) {
            Picker("Limit Range", selection: $limitedTime) {
              Text("Forever").tag(0)
              Text("Between").tag(1)
              Text("x Times").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 4)
            .padding(.bottom, 4)
          }

          if limitedTime == 1 {
            Section(header: Text("Start Date")) {
              DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
            }

            Section(header: Text("End Date")) {
              DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
            }
          } else if limitedTime == 2 {
            Section(header: Text("Occurrences")) {
              Stepper(
                value: $occurrences, in: 1...9999,
                label: {
                  Text("\(occurrences) \(occurrences == 1 ? "Occurrence" : "Occurrences")")
                })
            }
          }

          // rrule
          Section(header: Text("Recurrence")) {
            Picker("Frequency", selection: $frequency) {
              Text("Daily").tag(EKRecurrenceFrequency.daily)
              Text("Weekly").tag(EKRecurrenceFrequency.weekly)
              Text("Monthly").tag(EKRecurrenceFrequency.monthly)
              Text("Yearly").tag(EKRecurrenceFrequency.yearly)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.top, 4)
            .padding(.bottom, 4)
            .onChange(of: frequency) { oldValue, newValue in
              if hasLoadedTaskData {
                selectedDays = []
                interval = 1
              }
            }

            if frequency == EKRecurrenceFrequency.daily {
              Stepper(
                value: $interval, in: 1...100,
                label: {
                  Text("Every \(interval) \(interval == 1 ? "day" : "days")")
                })
            } else if frequency == EKRecurrenceFrequency.weekly {
              Stepper(
                value: $interval, in: 1...100,
                label: {
                  Text("Every \(interval) \(interval == 1 ? "week" : "weeks")")
                })
            } else if frequency == EKRecurrenceFrequency.monthly {
              Stepper(
                value: $interval, in: 1...100,
                label: {
                  Text("Every \(interval) \(interval == 1 ? "month" : "months")")
                })
            } else if frequency == EKRecurrenceFrequency.yearly {
              Stepper(
                value: $interval, in: 1...100,
                label: {
                  Text("Every \(interval) \(interval == 1 ? "year" : "years")")
                })
            }
          }

          if frequency != EKRecurrenceFrequency.daily {
            Section(header: Text("Recurrence Dates")) {
              if frequency == EKRecurrenceFrequency.weekly {
                List {
                  ForEach(1..<8) { index in
                    MultipleSelectionRow(
                      text: self.weekdays[index - 1],
                      isSelected: self.selectedDays.contains(intToEKRecurrenceDayOfWeekMap[index]!)
                    ) {
                      if self.selectedDays.contains(intToEKRecurrenceDayOfWeekMap[index]!) {
                        self.selectedDays.remove(intToEKRecurrenceDayOfWeekMap[index]!)
                      } else {
                        self.selectedDays.insert(intToEKRecurrenceDayOfWeekMap[index]!)
                      }
                    }
                  }
                }
                .id(selectedDays.count)
              } else if frequency == EKRecurrenceFrequency.monthly {
                Picker("type", selection: $byType) {
                  Text("By Date").tag("date")
                  Text("By Day").tag("day")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 4)
                .padding(.bottom, 4)
                .onChange(of: byType) { new, old in
                  if hasLoadedTaskData {
                    selectedDays = []
                    selectedDates = []
                  }
                }
                if byType == "date" {
                  LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 10) {
                    ForEach(1..<32) { day in
                      DayButton(
                        day: day,
                        isSelected: self.selectedDates.contains(NSNumber(value: day))
                      ) {
                        if self.selectedDates.contains(NSNumber(value: day)) {
                          self.selectedDates.remove(NSNumber(value: day))
                        } else {
                          self.selectedDates.insert(NSNumber(value: day))
                        }
                      }
                    }
                  }
                } else {
                  List {
                    ForEach(0..<42) { index in
                      let dayOfWeek: EKRecurrenceDayOfWeek = intToEKRecurrenceDayOfWeekMap[
                        (index % 7) + 1]!
                      let weekNumber = Int(index / 7) + 1
                      let EKRDOW = EKRecurrenceDayOfWeek(
                        dayOfWeek.dayOfTheWeek, weekNumber: weekNumber)

                      MultipleSelectionRow(
                        text: "\(nth[Int(index/7)]) \(self.weekdays[index % 7])",
                        isSelected: self.selectedDays.contains(EKRDOW)
                      ) {
                        if self.selectedDays.contains(EKRDOW) {
                          self.selectedDays.remove(EKRDOW)
                        } else {
                          self.selectedDays.insert(EKRDOW)
                        }
                      }
                    }
                  }
                }
              } else if frequency == EKRecurrenceFrequency.yearly {
                Picker("type", selection: $byType) {
                  Text("By Date").tag("date")
                  Text("By Day").tag("day")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.top, 4)
                .padding(.bottom, 4)
                List {
                  ForEach(1..<13) { index in
                    MultipleSelectionRow(
                      text: "\(months[index-1])",
                      isSelected: self.selectedMonths.contains(NSNumber(value: index))
                    ) {
                      if self.selectedMonths.contains(NSNumber(value: index)) {
                        self.selectedMonths.remove(NSNumber(value: index))
                      } else {
                        self.selectedMonths.insert(NSNumber(value: index))
                      }
                    }
                  }
                }
                if byType == "date" {
                  LazyVGrid(columns: Array(repeating: GridItem(), count: 7), spacing: 10) {
                    ForEach(1..<32) { day in
                      DayButton(
                        day: day,
                        isSelected: self.selectedDates.contains(NSNumber(value: day))
                      ) {
                        if self.selectedDates.contains(NSNumber(value: day)) {
                          self.selectedDates.remove(NSNumber(value: day))
                        } else {
                          self.selectedDates.insert(NSNumber(value: day))
                        }
                      }
                    }
                  }
                } else {
                  Spacer().frame(height: 30)
                  List {
                    ForEach(0..<42) { index in
                      let dayOfWeek: EKRecurrenceDayOfWeek = intToEKRecurrenceDayOfWeekMap[
                        (index % 7) + 1]!
                      let weekNumber = Int(index / 7) + 1
                      let EKRDOW = EKRecurrenceDayOfWeek(
                        dayOfWeek.dayOfTheWeek, weekNumber: weekNumber)

                      MultipleSelectionRow(
                        text: "\(nth[Int(index/7)]) \(self.weekdays[index % 7])",
                        isSelected: self.selectedDays.contains(EKRDOW)
                      ) {
                        if self.selectedDays.contains(EKRDOW) {
                          self.selectedDays.remove(EKRDOW)
                        } else {
                          self.selectedDays.insert(EKRDOW)
                        }
                      }
                    }
                  }
                }
              }
            }
          }
          Button(action: {
            Task {
              await createTask()
            }
          }) {
            Text("Save")
              .bold()
              .foregroundColor(Color(UIColor.systemBackground))
              .frame(height: 50)
              .frame(maxWidth: .infinity)
              .background(waiting ? .gray : theme)
              .cornerRadius(10)
              .disabled(waiting)
              .contentShape(Rectangle())
          }
          .listRowBackground(Color.clear)
        }
      }
      .simultaneousGesture(
        DragGesture().onChanged({
          if 0 < $0.translation.height {
            self.endTextEditing()
          }
        })
      )
    }
    .navigationBarTitle(editMode ? "Edit Task" : "Create New Task", displayMode: .inline)
    .contentShape(Rectangle())
    .onAppear {
      Task {
        await getDynamic()
      }

      if editMode {
        name = habitTask.name
        desc = habitTask.description
        value = habitTask.value
        max = habitTask.max_count
        target = habitTask.target_count
        rrule = habitTask.rrule

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let start = dateFormatter.date(from: habitTask.start ?? "")
        let end = dateFormatter.date(from: habitTask.end ?? "")

        startDate = start ?? Date()
        endDate = end ?? Date()

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        remindTime = timeFormatter.date(from: habitTask.remind_time ?? "") ?? Date()
        restrictTime = timeFormatter.date(from: habitTask.restrict_time ?? "") ?? Date()

        remove_points_on_failure = habitTask.remove_points_on_failure == 1 ? true : false
        remind = habitTask.remind == 1 ? true : false
        restrict = habitTask.restrict == 1 ? true : false
        restrictBefore = habitTask.restrict_before == 1 ? true : false

        let EKRRule = EKRecurrenceRule.recurrenceRuleFromString(rrule)
        frequency = EKRRule?.frequency ?? .daily
        interval = EKRRule?.interval ?? 1
        selectedDays = Set(EKRRule?.daysOfTheWeek ?? [])
        selectedDates = Set(EKRRule?.daysOfTheMonth ?? [])
        selectedMonths = Set(EKRRule?.monthsOfTheYear ?? [])
        occurrences = 1
        limitedTime = 0
        byType = selectedDays.count > 0 ? "day" : "date"

        let pattern = "COUNT=([0-9]+)"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(rrule.startIndex..<rrule.endIndex, in: rrule)
        if let match = regex.firstMatch(in: rrule, options: [], range: range) {
          let countRange = Range(match.range(at: 1), in: rrule)!
          let countString = String(rrule[countRange])
          if let count = Int(countString) {
            occurrences = count
            limitedTime = 2
          }
        }

        if !Calendar.current.isDateInToday(endDate) {
          limitedTime = 1
        }

        Task {
          hasLoadedTaskData = true
        }
      }
    }
    .simpleToast(
      isPresented: $showToast, options: SimpleToastOptions(alignment: .bottom, hideAfter: 5)
    ) {
      Label("Whoops! Something went wrong.", systemImage: "exclamationmark.triangle")
        .padding()
        .background(Color.red.opacity(0.8))
        .foregroundColor(Color.white)
        .cornerRadius(10)
        .padding(.top)
    }
  }

  struct DayButton: View {
    let day: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
      Button(action: {
        self.action()
      }) {
        Text("\(day < 10 ? "0" : "")\(day)")
          .frame(width: 40, height: 40)
          .background(isSelected ? theme : .clear)
          .foregroundColor(isSelected ? Color(UIColor.systemBackground) : theme)
          .cornerRadius(40)
      }
      .buttonStyle(PlainButtonStyle())
    }
  }

  struct MultipleSelectionRow: View {
    var text: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
      Button(action: {
        self.action()
      }) {
        HStack {
          Text(text)
            .frame(maxWidth: .infinity, alignment: .leading)
          if isSelected {
            Image(systemName: "checkmark.circle.fill")
              .foregroundColor(theme)
          }
        }
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
    }
  }

  func generateRecurrenceRule() {
    let recurrenceRule = EKRecurrenceRule(
      recurrenceWith: frequency,
      interval: interval,
      daysOfTheWeek: Array(selectedDays),
      daysOfTheMonth: Array(selectedDates),
      monthsOfTheYear: frequency == EKRecurrenceFrequency.yearly ? Array(selectedMonths) : nil,
      weeksOfTheYear: [],
      daysOfTheYear: [],
      setPositions: [],
      end: nil
    )

    if limitedTime == 2 {
      recurrenceRule.recurrenceEnd = EKRecurrenceEnd(occurrenceCount: occurrences)
    }

    rrule = String(
      describing: recurrenceRule
        .description
        .components(separatedBy: "> ")
        .last ?? ""
    )
    .replacingOccurrences(of: " ", with: ":")
  }

  func getDynamic() async {
    waiting = true
    var request = createAuthRequest(url: base_url + "/api/dynamic")
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      waiting = false
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonDynamicBase.self, from: data) {
          dynamic = Dynamic(
            id: jsonData.dynamic?.id ?? 0,
            name: jsonData.dynamic?.name ?? "",
            UUID: jsonData.dynamic?.UUID ?? "",
            sub: jsonData.dynamic?.sub ?? "",
            dom: jsonData.dynamic?.dom ?? "",
            time_zone: jsonData.dynamic?.time_zone ?? "",
            default_reward_emojis: jsonData.dynamic?.default_reward_emojis ?? "",
            created_at: jsonData.dynamic?.created_at ?? "",
            created_at_humans: jsonData.dynamic?.created_at_humans ?? ""
          )
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
    }.resume()
  }

  func createTask() async {
    waiting = true
    generateRecurrenceRule()
    var request = createAuthRequest(
      url: base_url + "/api/task" + (editMode ? "/\(habitTask.id)" : "s"))
    request.httpMethod = editMode ? "PUT" : "POST"

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let timeFormatter = DateFormatter()
    timeFormatter.dateFormat = "HH:mm:ss"

    let components = Calendar.current.dateComponents([.hour, .minute], from: remindTime)
    let remindTimeWithZeroSeconds = Calendar.current.date(from: components)!
    let components2 = Calendar.current.dateComponents([.hour, .minute], from: restrictTime)
    let restrictTimeWithZeroSeconds = Calendar.current.date(from: components2)!

    let body: [String: Any] = [
      "name": name,
      "description": desc,
      "value": value,
      "max_count": max,
      "target_count": target,
      "rrule": rrule,
      "start": dateFormatter.string(from: startDate),
      "end": limitedTime == 1 ? dateFormatter.string(from: endDate) : "",
      "remove_points_on_failure": remove_points_on_failure ? 1 : 0,
      "remind": remind ? 1 : 0,
      "remind_time": timeFormatter.string(from: remindTimeWithZeroSeconds),
      "restrict": restrict ? 1 : 0,
      "restrict_before": restrictBefore ? 1 : 0,
      "restrict_time": timeFormatter.string(from: restrictTimeWithZeroSeconds),
    ]
    print(body)
    let jsonData = try? JSONSerialization.data(withJSONObject: body)
    request.httpBody = jsonData

    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let data = data {
        if let jsonData = try? JSONDecoder().decode(JsonCompleteMessageBase.self, from: data) {
          if jsonData.message == "something went wrong" {
            showToast = true
          } else {
            Task { @MainActor in
              habitTask = HabitTask(
                id: habitTask.id,
                group_id: habitTask.group_id,
                color: habitTask.color,
                name: name,
                description: desc,
                value: value,
                count: habitTask.count,
                max_count: max,
                target_count: target,
                history: habitTask.history,
                rrule: rrule,
                start: limitedTime == 1 ? dateFormatter.string(from: startDate) : "",
                end: limitedTime == 1 ? dateFormatter.string(from: endDate) : "",
                remove_points_on_failure: remove_points_on_failure ? 1 : 0,
                is_task_due_today: habitTask.is_task_due_today,
                rule_text: habitTask.rule_text,
                remind: remind ? 1 : 0,
                remind_time: timeFormatter.string(from: remindTime),
                restrict: restrict ? 1 : 0,
                restrict_before: restrictBefore ? 1 : 0,
                restrict_time: timeFormatter.string(from: restrictTime),
                time_zone: dynamic.time_zone
              )
              self.presentation.wrappedValue.dismiss()
            }
          }
        } else {
          showToast = true
        }
      } else {
        showToast = true
      }
      waiting = false
    }.resume()
  }
}
