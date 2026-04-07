import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var catProfiles: [CatProfile]
    @Query(sort: \CareEvent.timestamp, order: .reverse)
    private var recentEvents: [CareEvent]

    @State private var showFeedingSheet = false
    @State private var showPlaySheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    quickActionButtons
                    weeklySummaryPlaceholder
                    recentTimelinePlaceholder
                }
                .padding()
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
            .sheet(isPresented: $showFeedingSheet) {
                RecordFeedingView()
            }
            .sheet(isPresented: $showPlaySheet) {
                RecordPlayView()
            }
        }
    }

    // MARK: - Subviews

    private var quickActionButtons: some View {
        HStack(spacing: 16) {
            QuickActionButton(
                title: "记录湿粮",
                icon: "fork.knife",
                color: .orange
            ) {
                showFeedingSheet = true
            }

            QuickActionButton(
                title: "记录玩耍",
                icon: "figure.play",
                color: .green
            ) {
                showPlaySheet = true
            }
        }
    }

    private var weeklySummaryPlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("本周摘要")
                .font(.headline)

            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .frame(height: 120)
                .overlay {
                    Text("周报数据将在后续迭代中实现")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
        }
    }

    private var recentTimelinePlaceholder: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("最近记录")
                .font(.headline)

            if recentEvents.isEmpty {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(height: 100)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.title2)
                                .foregroundStyle(.tertiary)
                            Text("还没有记录")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                        }
                    }
            } else {
                ForEach(recentEvents.prefix(5)) { event in
                    EventRowView(event: event, catProfiles: catProfiles)
                }
            }
        }
    }
}

// MARK: - Quick Action Button

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .foregroundStyle(.white)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - Event Row View

struct EventRowView: View {
    let event: CareEvent
    let catProfiles: [CatProfile]

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(eventTitle)
                    .font(.subheadline.weight(.medium))
                Text(event.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if let catName {
                Text(catName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Helpers

    private var iconName: String {
        switch event.eventType {
        case .feeding: "fork.knife"
        case .treat: "gift"
        case .play: "figure.play"
        case .training: "star"
        case .away: "house"
        case .outing: "figure.walk"
        case .deworming: "cross.case"
        }
    }

    private var iconColor: Color {
        switch event.eventType {
        case .feeding: .orange
        case .treat: .pink
        case .play: .green
        case .training: .purple
        case .away: .blue
        case .outing: .teal
        case .deworming: .red
        }
    }

    private var eventTitle: String {
        switch event.eventType {
        case .feeding:
            let foodName = event.metadata[FeedingMetadataKey.foodName] ?? ""
            let source = event.source == .petlibro ? "干粮(自动)" : "湿粮"
            return foodName.isEmpty ? source : "\(source) · \(foodName)"
        case .treat:
            let name = event.metadata[TreatMetadataKey.treatName] ?? "零食"
            return "🍬 \(name)"
        case .play:
            let minutes = event.metadata[PlayMetadataKey.durationMinutes] ?? ""
            return minutes.isEmpty ? "玩耍" : "玩耍 · \(minutes)分钟"
        case .training:
            let milestone = event.metadata[TrainingMetadataKey.milestoneName] ?? "训练"
            return "🎯 \(milestone)"
        case .away:
            let minutes = event.metadata[AwayMetadataKey.durationMinutes] ?? ""
            return minutes.isEmpty ? "离家" : "离家 · \(minutes)分钟"
        case .outing:
            return "带猫出门"
        case .deworming:
            let drug = event.metadata[DewormingMetadataKey.drugName] ?? "驱虫"
            return "💊 \(drug)"
        }
    }

    private var catName: String? {
        guard let catId = event.catId else { return nil }
        return catProfiles.first { $0.id == catId }?.name
    }
}
