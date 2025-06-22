//
//  CoreDataManager.swift
//  BookXPAssign
//
//  Created by vikash kumar on 21/06/25.
//

import Foundation
import CoreData

class CoreDataManager {
    let container: NSPersistentContainer
    
    static var shared = CoreDataManager()
    
    private init() {
        container = NSPersistentContainer(name: "BookXPDB")
        
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        
        
        container.loadPersistentStores { description, error in
            if let error = error {
                // Handle Error
                print("Error In Loading Core Data Store: \(error.localizedDescription)")
            } else if let url = description.url {
                // Url store will use for its location.
                print("Core Data Loaded Successfully From: \(url.path)")
            }
        }
    }
    
    func persistUserDetails(from userData: UserDataModel) async -> Bool {
        await deleteUser(with: userData.email)
        // Persist on background context
        let backgroundContext = container.newBackgroundContext()
        let user = User(context: backgroundContext)
        user.email = userData.email
        user.fullName = userData.fullName
        user.firstname = userData.firstName
        user.familyName = userData.familyName
        user.profileImage = userData.profileurl
        do {
            try backgroundContext.save()
            print("User data saved successfully")
            return true
        } catch {
            // Handle Error
            print("Failed to save user: \(error)")
            return false
        }
    }
    
    func fetchUserDetails(with email: String) -> UserDataModel? {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            let users = try context.fetch(fetchRequest)
            // As there is only a single user at a time
            if let user = users.first {
                return UserDataModel(
                    fullName: user.fullName ?? "",
                    firstName: user.firstname ?? "",
                    familyName: user.familyName ?? "",
                    email: user.email ?? "",
                    profileurl: user.profileImage ?? ""
                )
            }
            return nil
        } catch {
            print("Failed to fetch User: \(error)")
            return nil
        }
    }
    
    func fetchOnlyUSer() -> UserDataModel? {
        let contex = container.viewContext
        let fetchrequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try contex.fetch(fetchrequest)
            if let user = users.first {
                print("User Data Found successfully ")
                return UserDataModel(
                    fullName: user.fullName ?? "",
                    firstName: user.firstname ?? "",
                    familyName: user.familyName ?? "",
                    email: user.email ?? "",
                    profileurl: user.profileImage ?? ""
                )
            }
            print("Do not found any user here!")
            return nil
        } catch {
            print("Failed to fetch User: \(error)")
            return nil
        }
    }
    
    func deleteUser(with email: String) async {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            guard let user = try context.fetch(fetchRequest).first else { return }
            
            context.delete(user)
            
            try context.save()
            print("User Deleted!")
        } catch {
            print("Failed to delete User: \(error)")
        }
    }
    
    func deleteUser() async {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            guard let user = try context.fetch(fetchRequest).first else { return }
            
            context.delete(user)
            
            try context.save()
            print("User Deleted!")
        } catch {
            print("Failed to delete User: \(error)")
        }
    }
}


// Portfolio Operations
extension CoreDataManager {
    
    func persistPortfolio(from data: [PortfolioData]) async {
        let backgroundContext = container.newBackgroundContext()
        
        await backgroundContext.perform {
            for item in data {
                let portfolio = Device(context: backgroundContext)
                portfolio.id = item.id
                portfolio.name = item.name
                portfolio.detail = item.data
            }
            do {
                try backgroundContext.save()
                print("User data saved successfully")
            } catch {
                // Handle Error
                print("Failed to save user: \(error)")
            }
        }
    }
    
    func fetchPortfolios() async -> [PortfolioData] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        do {
            let devices = try await context.perform {
                try context.fetch(fetchRequest)
            }
            return devices.map({ PortfolioData(device: $0) }).sorted(by: {(Int($0.id ?? "") ?? 0) < (Int($1.id ?? "") ?? 0)})
        } catch {
            print("Error:: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteAllPortfolios() async {
        let context = container.viewContext
        let fetchrequest: NSFetchRequest<NSFetchRequestResult> = Device.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchrequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("All Data Delete successfully!")
        } catch {
            print("Failed to delete all data :: \(error.localizedDescription)")
        }
    }
    
    func deletePortfolio(id: String) async {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            if let device = try context.fetch(fetchRequest).first {
                context.delete(device)
            }
            try context.save()
        } catch {
            print("Failed to delete:: \(error.localizedDescription)")
        }
    }
    
    func updatePortfolio(with portFolio: PortfolioData) async -> Bool {
        guard let id = portFolio.id else {
            print("Portfoilo ID is nil")
            return false
        }
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Device> = Device.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            if let device = try context.fetch(fetchRequest).first {
                device.name = portFolio.name
                
                if let deviceDetail = portFolio.data {
                    let encodedData = try? JSONEncoder().encode(deviceDetail)
                    device.detailData = encodedData
                }
                
                try context.save()
                return true
            } else {
                print("Device with id \(id) not found.")
                return false
            }
        } catch {
            print("Failed to delete:: \(error.localizedDescription)")
            return false
        }
    }
}
