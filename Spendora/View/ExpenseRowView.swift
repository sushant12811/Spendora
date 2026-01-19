//
//  ExpenseRowView.swift
// Spendora
//
//  Created by Sushant Dhakal on 2026-01-12.
//

import SwiftUI

struct ExpenseRowView: View {
    let expense : ExpenseModel
    let currencySymbol : String
    let onTapDelete : (ExpenseModel) -> Void
    
    
    var body: some View {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(expense.category.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: expense.category.icon)
                        .foregroundStyle(expense.category.color)
                        .font(.title3)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(expense.title)
                        .font(.headline)
                    Text(expense.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(expense.date, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(currencySymbol) \(expense.amount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundStyle(expense.category.color)
            }
            .contextMenu{
                Button("Delete", role: .destructive) {
                    onTapDelete(expense)
                }
                
               
            }
            
    }
}

#Preview {
    ExpenseRowView(expense: .sampleData[0], currencySymbol: "", onTapDelete: { _ in })
}
