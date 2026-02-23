import SwiftUI

struct TimeAgoLabel: View {
    let date: Date

    var body: some View {
        Text(date.timeAgo)
            .font(.system(size: 11))
            .foregroundStyle(.tertiary)
            .help(date.formatted(date: .abbreviated, time: .shortened))
            .accessibilityLabel("Copiado \(date.timeAgoFull)")
    }
}
