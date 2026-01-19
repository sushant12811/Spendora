//
//  ContentView.swift
//  Spendora
//
//  Created by Sushant Dhakal on 2025-10-17.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExpenseModel.date, order: .reverse) private var expense:
        [ExpenseModel]
    @Environment(\.colorScheme) private var colorScheme
    

    @State private var selectedFilter: FilteredOption = .all
    @State private var selectedCategory: CategoryFiltered = .all
    @AppStorage("selectedMode") private var selectedMode: ColorMode = .system
    @State private var showAddExpenseView: Bool = false
    @State private var showAlert: Bool = false
    @State private var selectCheckMark: Bool = false
    @AppStorage("infoHint") private var firstTimeInfoHint: Bool = true
    @AppStorage("currency_unit") private var selectedCurrency: CurrencyUnit = .CAD
    @State private var searchQuery: String = ""
  

    enum FilteredOption: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var filteredExpenses: [ExpenseModel] {
        
        let now = Date()
        let calender = Calendar.current
        
        let filterdByDate: [ExpenseModel] = {
            switch selectedFilter {
            case .all:
                return expense
            case .today:
                return expense.filter { calender.isDateInToday($0.date) }
            case .week:
                return expense.filter {
                    calender.isDate(
                        $0.date,
                        equalTo: now,
                        toGranularity: .weekOfYear
                    )
                }
            case .month:
                return expense.filter {
                    calender.isDate($0.date, equalTo: now, toGranularity: .month)
                }
            case .year:
                return expense.filter {
                    calender.isDate($0.date, equalTo: now, toGranularity: .year)
                }
            }
        }()
        
        let filteredByCategory:[ExpenseModel] = {
            switch selectedCategory {
            case .all:
                return filterdByDate
                
            case .category(let category):
                return filterdByDate.filter { $0.category == category }
            }
        }()
        
        
        guard !searchQuery.isEmpty else { return filteredByCategory }
        
        return filteredByCategory.filter{
            $0.title.localizedCaseInsensitiveContains(searchQuery) || $0.category.rawValue.localizedCaseInsensitiveContains(searchQuery)
            
            
        }
    }

    var totalAmount: Double {
        filteredExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        
        NavigationStack {
            ZStack(alignment: .bottom) {

                expenseListView
                    .navigationTitle("Expenses")
                    .navigationDestination(for: ExpenseModel.self) { expense in
                        ExpenseView(expense: expense)
                    }
                    .sheet(isPresented: $showAddExpenseView) {
                        NavigationStack {
                            ExpenseView()
                        }
                    }
                    .alert(filteredExpenses.count > 1 ? "DeleteAll" : "Delete?", isPresented: $showAlert) {
                        Button("Delete", role: .destructive) {
                            deleteALL()
                        }

                    } message: {
                        Text(filteredExpenses.count < 1 ? "Are you sure want to delete it?" : "Are you sure want to delete all expenses?")
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu("Filter Options", systemImage: "ellipsis.circle") {
                                Menu("Filter", systemImage: "slider.horizontal.3"){
                                    Picker("Category", selection: $selectedCategory){
                                        ForEach(CategoryFiltered.allCases, id: \.self) { cat in
                                            Label(cat.title, systemImage: cat.icon)
                                                .tag(cat)
                                        }
                                    }
                                }
                                
                                Menu("Mode", systemImage: "circle.lefthalf.filled.inverse"){
                                    Picker("Select Mode",  selection: $selectedMode) {
                                        ForEach(ColorMode.allCases, id: \.self){mode in
                                            Label("\(mode.rawValue.capitalized)", systemImage:"\(mode.icon)")
                                        }
                                    }
                                }
                                
                               
                                
                            }
                        }
                    }
                
                VStack(spacing: 20){
                    if firstTimeInfoHint{
                        Text("Add your first expense by tapping \"+\" below")
                            .font(.caption)
                            .padding(10)
                            .background(.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .pulseEffect()
                            
                    }
                    
                    Button {
                        showAddExpenseView = true
                        firstTimeInfoHint = false

                    } label: {
                        Image(systemName: "plus")
                            .font(.title).fontWeight(.semibold)
                            .tint(.gray)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.primary)
                                    .shadow(color: .black.opacity(0.5), radius: 0.2)
                            )
                    }
                }.padding()

            }

        }
        .preferredColorScheme(selectedMode.colorScheme)

    }

    //MARK: ExpenseListView
    private var expenseListView: some View {
        VStack(spacing: 0) {
            // MARK: Header
            VStack(spacing: 8) {
                Text("Total Expenses")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(selectedCurrency.currSymbol) \(totalAmount, specifier: "%.2f")")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Picker("Filter", selection: $selectedFilter) {
                    ForEach(FilteredOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                HStack {
                    Spacer()
                    Button {
                        showAlert = true
                    } label: {
                        if !filteredExpenses.isEmpty {
                            Text(filteredExpenses.count > 1 ? "Delete All" :"Delete")
                                .foregroundStyle(.red.opacity(0.7))
                                .font(.caption2)
                                .padding(8)
                                .background(.red.opacity(0.2))
                                .clipShape(Capsule())
                            
                        }
                       
                    }
                    .disabled(filteredExpenses.isEmpty)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGroupedBackground))

            // MARK: List of expenses
            if expense.isEmpty {
                expenseListEmpty()
            } else {
                List {
                    if filteredExpenses.isEmpty {
                        HStack{
                            Spacer()
                            Text("Sorry, no results.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                    }else{
                        
                        ForEach(filteredExpenses) { expense in
                            NavigationLink(value: expense) {
                                ExpenseRowView(expense: expense, currencySymbol: selectedCurrency.currSymbol){ expenseToDelete in
                                    deleteSelectedItem(expense: expenseToDelete)
                                }
                            }
                        }
                        .onDelete { index in
                            deleteIndividual(offsets: index)
                        }
                        
                    }

                }
                .searchable(text: $searchQuery, placement: .navigationBarDrawer, prompt: "Search for an Expense...")

            }
        }
    }

    // MARK: Empty list placeholder
    private func expenseListEmpty() -> some View {
        VStack {
            Image(systemName: "tray")
                .font(.system(size: 60))
            Text("No expenses yet")
            Text("Add + to add your first expense")
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .frame(maxHeight: .infinity)
        .padding(.bottom,10)
    }

    //MARK: Delete Individual
    private func deleteIndividual(offsets: IndexSet) {
        for index in offsets {
            let expense = filteredExpenses[index]
            modelContext.delete(expense)
        }
        try? modelContext.save()
    }
    
    func deleteSelectedItem(expense: ExpenseModel) {
        modelContext.delete(expense)
    }

    //MARK: Delete ALL
    private func deleteALL() {
    for expense in filteredExpenses {
                modelContext.delete(expense)
            }
            try? modelContext.save()
    }
}

#Preview {
    ContentView()

}
