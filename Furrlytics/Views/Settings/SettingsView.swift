import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("猫咪") {
                NavigationLink {
                    CatProfileSettingsView()
                } label: {
                    Label("猫咪管理", systemImage: "cat.fill")
                }
            }

            Section("位置") {
                NavigationLink {
                    HomeLocationSettingsView()
                } label: {
                    Label("家的位置", systemImage: "house.fill")
                }
            }

            Section("喂食器") {
                NavigationLink {
                    PetlibroSettingsView()
                } label: {
                    Label("Petlibro 连接", systemImage: "wifi.router.fill")
                }
            }
        }
        .navigationTitle("设置")
    }
}
