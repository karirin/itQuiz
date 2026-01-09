//
//  UIComponentsUpdated.swift
//  it
//
//  Modern reusable UI components with premium design
//

import SwiftUI

// MARK: - Design Tokens
struct DesignTokens {
    // Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // Corner Radius
    struct Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let full: CGFloat = 9999
    }
    
    // Shadows
    struct Shadow {
        static let sm = (color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        static let md = (color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
        static let lg = (color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
        static let xl = (color: Color.black.opacity(0.25), radius: 24, x: 0, y: 12)
    }
}

// MARK: - Primary Button
struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    var isLoading: Bool = false
    var isDisabled: Bool = false
    
    @State private var isPressed = false
    
    init(title: String, icon: String? = nil, isLoading: Bool = false, isDisabled: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            guard !isLoading && !isDisabled else { return }
            generateHapticFeedback()
            action()
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                    }
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    // Gradient background
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                        .fill(
                            LinearGradient(
                                colors: isDisabled ?
                                    [Color.gray.opacity(0.5), Color.gray.opacity(0.4)] :
                                    [Color(red: 0.5, green: 0.3, blue: 0.95), Color(red: 0.3, green: 0.5, blue: 0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Inner highlight
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.clear],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .padding(1)
                }
            )
            .shadow(color: isDisabled ? Color.clear : Color.purple.opacity(0.4), radius: 12, x: 0, y: 6)
            .scaleEffect(isPressed ? 0.96 : 1)
            .opacity(isDisabled ? 0.6 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isDisabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isDisabled && !isLoading {
                        withAnimation(.spring(response: 0.2)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2)) {
                        isPressed = false
                    }
                }
        )
    }
}

// MARK: - Secondary Button
struct SecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            generateHapticFeedback()
            action()
        }) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                        .fill(Color.white.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                }
            )
            .scaleEffect(isPressed ? 0.96 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2)) { isPressed = false }
                }
        )
    }
}

// MARK: - Icon Button
struct IconButton: View {
    let icon: String
    let size: CGFloat
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(icon: String, size: CGFloat = 44, color: Color = .white, action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            generateHapticFeedback()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: size, height: size)
                
                Image(systemName: icon)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(color)
            }
            .scaleEffect(isPressed ? 0.9 : 1)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.spring(response: 0.2)) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.2)) { isPressed = false }
                }
        )
    }
}

// MARK: - Glass Card
struct GlassCardModern<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = DesignTokens.Radius.xl
    var padding: CGFloat = DesignTokens.Spacing.lg
    
    init(cornerRadius: CGFloat = DesignTokens.Radius.xl, padding: CGFloat = DesignTokens.Spacing.lg, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.padding = padding
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.white.opacity(0.05))
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Gradient Card
struct GradientCard<Content: View>: View {
    let content: Content
    let colors: [Color]
    var cornerRadius: CGFloat = DesignTokens.Radius.xl
    
    init(colors: [Color], cornerRadius: CGFloat = DesignTokens.Radius.xl, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.colors = colors
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                }
            )
            .shadow(color: colors.first?.opacity(0.4) ?? Color.clear, radius: 16, x: 0, y: 8)
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let text: String
    let color: Color
    var size: BadgeSize = .medium
    
    enum BadgeSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 10
            case .medium: return 12
            case .large: return 14
            }
        }
        
        var padding: (h: CGFloat, v: CGFloat) {
            switch self {
            case .small: return (8, 4)
            case .medium: return (12, 6)
            case .large: return (16, 8)
            }
        }
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, size.padding.h)
            .padding(.vertical, size.padding.v)
            .background(
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let gradient: [Color]
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, size: CGFloat = 60, lineWidth: CGFloat = 6, gradient: [Color] = [.purple, .blue]) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.gradient = gradient
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    AngularGradient(
                        colors: gradient + [gradient.first!],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.spring(response: 1, dampingFraction: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Animated Counter
struct AnimatedCounter: View {
    let value: Int
    let font: Font
    let color: Color
    
    @State private var displayValue: Int = 0
    
    init(value: Int, font: Font = .system(size: 32, weight: .bold, design: .rounded), color: Color = .white) {
        self.value = value
        self.font = font
        self.color = color
    }
    
    var body: some View {
        Text("\(displayValue)")
            .font(font)
            .foregroundColor(color)
            .contentTransition(.numericText())
            .onAppear {
                animateValue()
            }
            .onChange(of: value) { _ in
                animateValue()
            }
    }
    
    private func animateValue() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            displayValue = value
        }
    }
}

// MARK: - Shimmer Effect
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.5)
                    .offset(x: phase * geo.size.width * 1.5 - geo.size.width * 0.25)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message: String
    let icon: String
    let type: ToastType
    
    enum ToastType {
        case success, error, warning, info
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .warning: return .orange
            case .info: return .blue
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(type.color)
            
            Text(message)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                        .stroke(type.color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)?
    var actionTitle: String?
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 100, height: 100)
                
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            
            if let action = action, let actionTitle = actionTitle {
                PrimaryButton(title: actionTitle, action: action)
                    .frame(width: 200)
            }
        }
        .padding(40)
    }
}

// MARK: - Preview
struct UIComponentsUpdated_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(red: 0.08, green: 0.08, blue: 0.12)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    PrimaryButton(title: "プレイ開始", icon: "play.fill") {}
                    
                    SecondaryButton(title: "設定", icon: "gearshape.fill") {}
                    
                    HStack(spacing: 20) {
                        BadgeView(text: "レア", color: .blue)
                        BadgeView(text: "NEW", color: .green, size: .small)
                        BadgeView(text: "LEGEND", color: .yellow, size: .large)
                    }
                    
                    ProgressRing(progress: 0.75, size: 100, lineWidth: 8)
                    
                    ToastView(message: "レベルアップしました！", icon: "arrow.up.circle.fill", type: .success)
                }
                .padding(20)
            }
        }
    }
}
