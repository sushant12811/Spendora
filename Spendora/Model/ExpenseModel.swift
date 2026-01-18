//
//  ExpenseModel.swift
//  Spendora
//
//  Created by Sushant Dhakal on 2025-10-17.
//

import SwiftUI
import SwiftData

@Model
class ExpenseModel{
    var title : String
    var amount : Double
    var category : Category
    var date = Date()
    var notes: String
    
    init( title: String, amount: Double, category: Category, date: Date = Date(), notes: String) {
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
        self.notes = notes
    }
    
    static let sampleData: [ExpenseModel] = [
        ExpenseModel(title: "Groceries", amount: 150.00, category: .food, notes: "Weekly shopping"),
        ExpenseModel(title: "Gas", amount: 30.00, category: .transportation, notes: "Monthly gas refill"),
        ExpenseModel(title: "Clothing", amount: 100.00, category : .shopping , notes: "Monthly shopping")
    ]
}

enum CurrencyUnit: String, CaseIterable {
    case CAD, USD, EUR, GBP, INR, JPY, SEK, ZAR, NPR
    
    
    var currSymbol: String{
        switch self{
        case .NPR: return "रू"
            
        default :
                let formatter = NumberFormatter()
                formatter.locale = Locale.current
                formatter.numberStyle = .currency
                formatter.currencyCode = self.rawValue
                
                return formatter.currencySymbol ?? self.rawValue
        }
        
    }
    
    var currencyFormat: String{
        let name = self.rawValue
        return "\(name)(\(currSymbol))"
    }
        
}

enum Category: String, CaseIterable, Codable, Hashable{

    case food = "Food"
    case transportation = "Transportation"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case health = "Health"
    case miscellaneous = "Miscellaneous"
    
    var icon: String {
        switch self{
        case .food :  
            "fork.knife"
        case .transportation:
            "car.fill"
        case .shopping:
            "cart.fill"
        case .entertainment:
            "tv.fill"
        case .health:
            "heart.fill"
        case .miscellaneous:
            "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
           switch self {
           case .food: return .orange
           case .transportation: return .blue
           case .shopping: return .pink
           case .entertainment: return .purple
           case .health: return .green
           case .miscellaneous: return .gray
           }
       }
   }

enum CategoryFiltered :CaseIterable, Hashable{
    case all
    case category(Category)
    
    static var allCases: [CategoryFiltered] {
        [.all] + Category.allCases.map { .category($0) }
        }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .category(let category): return category.rawValue
        }
    }
    
    var icon: String {
            switch self {
            case .all:
                return "line.3.horizontal.decrease.circle"
            case .category(let cat):
                return cat.icon
            }
        }
}

enum ColorMode: String, CaseIterable, Codable, Hashable{
    case light
    case dark
    case system
    
    var icon: String {
        switch self{
        case .light :  
            "sun.max.fill"
        case .dark:
            "moon.stars.fill"
        case .system:
            "circle.lefthalf.filled"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .none
        }
    }
}
    

