import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var catProfiles: [CatProfile]

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "cat.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.tint)
                Text("欢迎使用喵谱")
                    .font(.largeTitle.bold())
                if let firstCat = catProfiles.first {
                    Text("你好，\(firstCat.name) 的主人！")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("更多功能将在后续迭代中实现")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom)
            }
            .navigationTitle("喵谱")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
        }
    }
}
