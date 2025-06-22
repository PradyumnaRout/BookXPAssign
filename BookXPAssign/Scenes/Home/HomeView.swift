//
//  HomeView.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import SwiftUI

struct HomeView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var homeVM = HomeViewModel()
    @State private var openSheet: Bool = false
    @State private var deleteAlert: Bool = false
    @State private var deleteItem: PortfolioData? = nil
    
    private var alertTitle: String = "Update Device Details"
    
    var body: some View {
        VStack {
            if !homeVM.listData.isEmpty {
                ScrollView(.vertical) {
                    VStack(spacing: 20) {
                        ForEach(homeVM.listData, id: \.id) { item in
                            VStack(spacing: 15) {
                                titleRow(item)
                                dataRow(item)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 10)
                            .background(.sheetBG)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 12)
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text(homeVM.isLoading ? "Loading Data..." : "No Data Found")
            }
        }
        
        // Delete Alert.
        .alert("Delete Item!", isPresented: $deleteAlert) {
            
            Button("Cancel") {
                deleteItem = nil
            }
            
            Button("Ok") {
                if let item = deleteItem, let id = deleteItem?.id {
                    homeVM.deleteItem(id, item)
                }
            }
            
        } message: {
            Text("Are you sure you want to delte the item?")
        }
        
        // Present Update Item Sheet
        .sheet(isPresented: $openSheet, content: {
            UpdateView(vm: homeVM)
                .presentationDetents([.height(450)])
        })
        .onChange(of: openSheet, { _, newValue in
            if !newValue {
                homeVM.selectedDevice = nil
            }
        })
    }
    
    private func dataRow(_ item: PortfolioData) -> some View {
        VStack(alignment: .leading) {
            
            Text("Color : **\(item.data?.color ?? "N/A")**")
            Text("Price : **\(String(format: "%.2f", item.data?.price ?? 0.00))**")
            Text("Memory : **\(item.data?.capacity ?? "N/A")**")
            
            if let generation = item.data?.generation {
                Text("Generation : **\(generation)**")
            }
            if let year = item.data?.year {
                Text("Year : **\(year)**")
            }

        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Title Row
    private func titleRow(_ item: PortfolioData) -> some View {
        HStack {
            Text(item.name ?? "No Name")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 10) {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .onTapGesture {
                        deleteAlert.toggle()
                        deleteItem = item
                    }
                
                Image(systemName: "pencil.circle.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundStyle(Color(UIColor.secondaryLabel))
                    .onTapGesture {
                        if let _ = item.id {
                            homeVM.selectedDevice = item
                            homeVM.extractEditableData()
                            openSheet.toggle()
                        }
                    }
            }
        }
    }
}

#Preview {
    HomeView()
}


struct UpdateView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject var vm: HomeViewModel
        
    var body: some View {
        VStack(spacing: 15) {
            
            Text(vm.name)
                .foregroundStyle(Color(uiColor: .label))
                .font(.title)
                .fontWeight(.bold)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
                .padding(.horizontal)
                        
            TextField("Enter Color", text: $vm.color)
                .textContentType(.name)
                .keyboardType(.alphabet)
                .textFieldBackground()
                .shake(with: vm.errorTextType == .color ? 5.0 : 0)
            
            TextField("Enter Memory", text: $vm.memory)
                .textFieldBackground()
                .keyboardType(.decimalPad)
                .shake(with: vm.errorTextType == .memory ? 5.0 : 0)

            TextField("Enter Price", text: $vm.price)
                .keyboardType(.decimalPad)
                .textFieldBackground()
                .shake(with: vm.errorTextType == .price ? 3.0 : 0)
            
            Spacer()
            
            HStack(spacing: 25) {
                
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                        .backgroundButton()
                }

                
                Button {
                    withAnimation {
                        vm.validateFields()
                    }
                    if vm.errorTextType == .non {
                        vm.updateItem()
                        dismiss()
                    }
                    vm.errorTextType = .non
                } label: {
                    Text("OK")
                        .backgroundButton()
                }
            }
            Spacer()
        }
    }
}

