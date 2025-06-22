//
//  AuthViewModel.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import Foundation
import Firebase
import GoogleSignIn
import FirebaseAuth

@MainActor
class AuthenticationViewModel: ObservableObject {
    
    // Auth state of user
    enum AuthState {
        case signedIn
        case signedOut
    }
    
    @Published var authState: AuthState = .signedOut
    var userData: UserDataModel?
    var tasks: [Task<()?, Never>] = []
    
    init() {
        userData = CoreDataManager.shared.fetchOnlyUSer()
        debugPrint("===== User data \(String(describing: userData)) =====")
        authState = userData != nil ? .signedIn : .signedOut
    }
    
    deinit { tasks.forEach({ $0.cancel() })}
    
    
    // Sing In
    func singIn() {
        // Previous user SingIn Check
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn {[weak self] (user, error) in
                let task = Task {
                    await self?.authenticateUser(for: user, with: error)
                }
                self?.tasks.append(task)
            }
        } else {
            guard let clientId = FirebaseApp.app()?.options.clientID else { return }
            
            let configuration = GIDConfiguration(clientID: clientId)
            GIDSignIn.sharedInstance.configuration = configuration
            
            guard let windowScene = UIApplication.shared
                    .connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first(where: { $0.activationState == .foregroundActive }),
                  let rootController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
                print("Could not find rootViewController.")
                return
            }
            
            // Singn In
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootController) {[weak self] (result, error) in
                let task = Task {
                    await self?.authenticateUser(for: result?.user, with: error)
                }
                self?.tasks.append(task)
            }
        }
    }
    
    
    // Authenticate User
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) async {
        
        guard error == nil else {
            print("===\(String(describing: error?.localizedDescription))===")
            return
        }
        
        guard let authUser = user, let idTokenString = authUser.idToken?.tokenString else { return }
        
        let profileUrlString = authUser.profile?.imageURL(withDimension: .min)?.absoluteString ?? ""
        // Converting to Model
        userData = UserDataModel(
            fullName: authUser.profile?.name ?? "",
            firstName: authUser.profile?.givenName ?? "",
            familyName: authUser.profile?.familyName ?? "",
            email: authUser.profile?.email ?? "",
            profileurl: profileUrlString
        )
        
        let credential = GoogleAuthProvider.credential(withIDToken: idTokenString, accessToken: authUser.accessToken.tokenString)
        
        do {
            try await Auth.auth().signIn(with: credential)
            if let data = userData {
                let _ =  await CoreDataManager.shared.persistUserDetails(from: data)
                self.authState = .signedIn
            }
        } catch {
            // Handle error throw
            print(error.localizedDescription)
        }
        
    }
    
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            authState = .signedOut
            Task{
                await CoreDataManager.shared.deleteUser()
                await CoreDataManager.shared.deleteAllPortfolios()
            }
        } catch {
            // Handle Error
            print(error.localizedDescription)
        }
    }
    
}
