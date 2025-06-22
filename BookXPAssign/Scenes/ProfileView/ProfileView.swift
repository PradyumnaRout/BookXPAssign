//
//  ProfileView.swift
//  BookXPAssign
//
//  Created by Pradyumna Rout on 21/06/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    // Properties
    @EnvironmentObject var authVM: AuthenticationViewModel
    @StateObject private var vm = ProfileViewModel()
    @StateObject private var cameraPermission:CameraPermission = CameraPermission()
    @StateObject private var galleryPermission:PhotoLibraryPermission = PhotoLibraryPermission()
    @State var profileImage: UIImage?
    @State var showPdfReader: Bool = false
    @State var enableNotification: Bool = true
    @State var confirmSignout: Bool = false
        
    var body: some View {
        ScrollView(.vertical) {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.prifleRectBG1)
                    .frame(width: AppConstants.screenWidth - 40, height: 130)
                
                profileImageView
                    .overlay(alignment: .bottomTrailing) {
                        Image(systemName: "pencil.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .offset(x: -15, y: -18)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.cyan, .prifleRectBG1)
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    vm.showPicker.toggle()
                                }
                            }
                    }
                
                VStack {
                    Text(vm.profileData?.fullName ?? "Hello")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(UIColor.label))
                    
                    Text(verbatim: vm.profileData?.email ?? "hii@gmail.com")
                        .foregroundColor(.gray)
                        .fontWeight(.regular)
                        .foregroundStyle(Color(UIColor.secondaryLabel))
                }
                
                bottomView
                Spacer()
                
            }
            .padding(.top, 50)
//            .redacted(reason: vm.profileData == nil ? .placeholder : [])
        }
        .alert("Sign Out!", isPresented: $confirmSignout, actions: {
            Button("Cancel") {}
            Button("Ok") {
                authVM.signOut()
            }
        }, message: {
            Text("Are you sure you want to sign out?.")
        })
        .alert("Permission Needed!", isPresented: $vm.alertForPermission, actions: {
            Button("Cancel") {}
            Button("Continue") {
                Task {
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        await UIApplication.shared.open(appSettings)
                    }
                }
            }
        }, message: {
            Text("Camera or Gallery access is currently off.Please enable it in Settings to continue.")
        })
        .sheet(isPresented: $showPdfReader, content: {
            PdfView()
        })
        .sheet(isPresented: $vm.showCamera, content: {
            ImagePickerManager(sourceType: .cameraImage) { image in
                profileImage = image
            }
        })
        .sheet(isPresented: $vm.showGallery, content: {
            ImagePickerManager(sourceType: .photoLibraryImage) { image in
                profileImage = image
            }
        })
        .sheet(isPresented: $vm.showPicker, content: {
            HStack(spacing: 15) {
                RoundedImageView(title: "Open Camera", iconName: "camera") {
                    print("Open Camera")
                    vm.showPicker.toggle()
                    vm.handleCameraTapped()
                }
                RoundedImageView(title: "Open Gallary",iconName: "photo.on.rectangle") {
                    print("Open Gallary")
                    vm.showPicker.toggle()
                    vm.handleGalleryTapped()
                }
            }
            .padding(.horizontal, 100)
            .presentationDetents([.height(200)])
        })
        .onAppear(perform: {
            enableNotification = UserDefaultsManager.shared.enableNotification
            if let urlString = vm.profileData?.profileurl {
                Task {
                    profileImage = try? await NetworkManager.downloadImage(withUrl: urlString)
                }
            }
        })
        .onChange(of: enableNotification, { _, newValue in
            if newValue {
                UserDefaultsManager.shared.enableNotification = true
            } else {
                NotificationManager.shared.cancelNotification()
                UserDefaultsManager.shared.enableNotification = false
            }
        })
    }
    
    @ViewBuilder
    private var profileImageView: some View {
        if profileImage != nil {
            Image(uiImage: profileImage!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipShape(
                    Circle()
                )
                .padding(4)
                .background(
                    Circle()
                        .fill(.profileBG)
                )
                .overlay(
                    Circle()
                        .stroke(.borderBG, lineWidth: 4)
                )
                .padding(8)
                .padding(.top, -100)
        } else {
            Image(.profilePlaceholder)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 150, height: 150)
                .clipShape(
                    Circle()
                )
                .padding(4)
                .background(
                    Circle()
                        .fill(.profileBG)
                )
                .overlay(
                    Circle()
                        .stroke(.borderBG, lineWidth: 4)
                )
                .padding(8)
                .padding(.top, -100)
            
        }
    }
    
    private var bottomView: some View {
        VStack {
            
            VStack(spacing: 18) {
                Toggle(isOn: $enableNotification) {
                    Text("Enable Notification")
                        .font(.title3)
                }
                
                Color(uiColor: .secondaryLabel).opacity(0.7)
                    .frame(height: 0.5)
            }
            .padding(.top, 100)
            
            VStack {
                Button(action: {
                    showPdfReader.toggle()
                }, label: {
                    VStack {
                        Text("Open pdf")
                            .foregroundStyle(Color(uiColor: .label))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 20)
                    }
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Color(uiColor: .secondaryLabel)
                    .frame(height: 0.5)
            }
            
            VStack {
                Button {
                    confirmSignout.toggle()
                } label: {
                    Text("Sign out")
                        .foregroundStyle(Color(uiColor: .label))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 20)
                }

                Color(uiColor: .secondaryLabel).opacity(0.7)
                    .frame(height: 0.5)
            }
        }
        .padding(.horizontal, 15)

    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationViewModel())
}

struct RoundedImageView: View {
    
    let title: String
    let iconName: String
    var tapHandler: (() -> Void)?
    
    var body: some View {
        
        VStack(spacing: 15) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
                .foregroundStyle(Color.black)
                .padding(.all, 15)
                .background(
                    Circle()
                        .fill(.white)
                )
                .overlay(
                    Circle()
                        .stroke(Color.black, lineWidth: 3)
                )
            
            Text(title)
                .font(.callout)
                .fontWeight(.semibold)

        }
        .padding(.vertical, 8)
        .frame(width: 150)
        .padding(.horizontal, 10)
        .background(
            Color.white.opacity(0.01)
        )
        .onTapGesture {
            self.tapHandler?()
        }

        
    }
}
