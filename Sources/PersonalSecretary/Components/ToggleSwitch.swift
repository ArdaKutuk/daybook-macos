import SwiftUI

/// Custom pill toggle switch matching the design (mint = on, beige = off),
/// used in place of the default `Toggle` style to stay pixel-faithful.
struct ToggleSwitch: View {
    @Binding var isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            RoundedRectangle(cornerRadius: DT.Radius.pill, style: .continuous)
                .fill(isOn ? DT.Color.toggleOn : DT.Color.toggleOff)
                .frame(width: DT.Size.toggleWidth, height: DT.Size.toggleHeight)
            Circle()
                .fill(Color.white)
                .frame(width: DT.Size.toggleKnob, height: DT.Size.toggleKnob)
                .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
                .padding(.horizontal, 2)
        }
        .contentShape(Rectangle())
        .onTapGesture { withAnimation(.easeInOut(duration: 0.15)) { isOn.toggle() } }
        .animation(.easeInOut(duration: 0.15), value: isOn)
    }
}
