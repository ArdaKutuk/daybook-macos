import SwiftUI

/// The round task/routine completion checkbox: empty ring when incomplete,
/// filled mint circle with a checkmark when complete.
struct CheckCircle: View {
    var isChecked: Bool
    var size: CGFloat = DT.Size.checkCircle
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isChecked ? DT.Color.mintDot : .clear)
                Circle()
                    .stroke(isChecked ? DT.Color.mintDot : DT.Color.scrollbarThumb, lineWidth: 1.5)
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.5, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}
