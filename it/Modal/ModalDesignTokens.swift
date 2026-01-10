//
//  ModalDesignSystem.swift
//  it
//
//  モダンで統一感のあるモーダルデザインシステム
//

import SwiftUI

// MARK: - Design Tokens

struct ModalDesignTokens {
    // Colors
    static let backgroundOverlay = Color.black.opacity(0.6)
    static let cardBackground = Color("Color2")
    static let cardBackgroundLight = Color.white
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let successGradient = LinearGradient(
        colors: [Color(hex: "11998e"), Color(hex: "38ef7d")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let warningGradient = LinearGradient(
        colors: [Color(hex: "f093fb"), Color(hex: "f5576c")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let coinGradient = LinearGradient(
        colors: [Color(hex: "f7971e"), Color(hex: "ffd200")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Shadows
    static let cardShadow = Color.black.opacity(0.25)
    static let buttonShadow = Color.black.opacity(0.15)
    
    // Dimensions
    static let cornerRadius: CGFloat = 24
    static let buttonCornerRadius: CGFloat = 16
    static let closeButtonSize: CGFloat = 36
    static let standardPadding: CGFloat = 24
    static let compactPadding: CGFloat = 16
    
    // Animation
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let easeOutAnimation = Animation.easeOut(duration: 0.25)
}

// MARK: - Modal Container View

struct ModalContainer<Content: View>: View {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let content: Content
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    init(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Background overlay with blur
            ModalDesignTokens.backgroundOverlay
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }
            
            // Modal content
            content
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(ModalDesignTokens.springAnimation) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
    
    private func dismissModal() {
        withAnimation(ModalDesignTokens.easeOutAnimation) {
            scale = 0.8
            opacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isPresented = false
            onDismiss?()
        }
    }
}

// MARK: - Modern Close Button

struct ModernCloseButton: View {
    let action: () -> Void
    var style: CloseButtonStyle = .floating
    
    enum CloseButtonStyle {
        case floating
        case inline
        case minimal
    }
    
    var body: some View {
        Button(action: {
            generateHapticFeedback()
            action()
        }) {
            ZStack {
                switch style {
                case .floating:
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: ModalDesignTokens.closeButtonSize, height: ModalDesignTokens.closeButtonSize)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary.opacity(0.7))
                    
                case .inline:
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                case .minimal:
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Modern Card View

struct ModernCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = ModalDesignTokens.standardPadding
    var cornerRadius: CGFloat = ModalDesignTokens.cornerRadius
    var backgroundColor: Color = ModalDesignTokens.cardBackgroundLight
    var showShadow: Bool = true
    
    init(
        padding: CGFloat = ModalDesignTokens.standardPadding,
        cornerRadius: CGFloat = ModalDesignTokens.cornerRadius,
        backgroundColor: Color = .white,
        showShadow: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
        self.showShadow = showShadow
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(
                        color: showShadow ? ModalDesignTokens.cardShadow : .clear,
                        radius: 20,
                        y: 10
                    )
            )
    }
}

// MARK: - Gradient Header

struct GradientHeader: View {
    let title: String
    var gradient: LinearGradient = ModalDesignTokens.primaryGradient
    var showCloseButton: Bool = true
    var closeAction: (() -> Void)?
    
    var body: some View {
        ZStack {
            gradient
            
            HStack {
                Spacer()
                
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .overlay(alignment: .trailing) {
                if showCloseButton {
                    ModernCloseButton(action: closeAction ?? {}, style: .inline)
                        .padding(.trailing, 16)
                }
            }
        }
        .frame(height: 56)
        .clipShape(
            RoundedCorner(radius: ModalDesignTokens.cornerRadius, corners: [.topLeft, .topRight])
        )
    }
}

// MARK: - Primary Action Button

struct PrimaryActionButton: View {
    let title: String
    var icon: String? = nil
    var gradient: LinearGradient = ModalDesignTokens.primaryGradient
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            generateHapticFeedback()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                Group {
                    if isDisabled {
                        Color.gray.opacity(0.4)
                    } else {
                        gradient
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: ModalDesignTokens.buttonCornerRadius))
            .shadow(
                color: isDisabled ? .clear : ModalDesignTokens.buttonShadow,
                radius: 8,
                y: 4
            )
        }
        .disabled(isDisabled)
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Secondary Action Button

struct SecondaryActionButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            generateHapticFeedback()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(Color("fontGray"))
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: ModalDesignTokens.buttonCornerRadius))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Floating Animation Modifier

struct FloatingAnimation: ViewModifier {
    @State private var isAnimating = false
    var amplitude: CGFloat = 6
    var duration: Double = 2.0
    
    func body(content: Content) -> some View {
        content
            .offset(y: isAnimating ? -amplitude : amplitude)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: duration)
                        .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    func floatingAnimation(amplitude: CGFloat = 6, duration: Double = 2.0) -> some View {
        modifier(FloatingAnimation(amplitude: amplitude, duration: duration))
    }
}

// MARK: - Shine Effect

struct ShineEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    .clear,
                                    .white.opacity(0.4),
                                    .clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 60)
                        .offset(x: isAnimating ? geometry.size.width + 60 : -60)
                        .onAppear {
                            withAnimation(
                                Animation.linear(duration: 2.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(1)
                            ) {
                                isAnimating = true
                            }
                        }
                }
                .clipped()
            )
    }
}

extension View {
    func shineEffect() -> some View {
        modifier(ShineEffect())
    }
}

// MARK: - Coin Display

struct CoinDisplay: View {
    let amount: String
    var size: CoinDisplaySize = .medium
    
    enum CoinDisplaySize {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 28
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 24
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "dollarsign.circle.fill")
                .font(.system(size: size.iconSize, weight: .semibold))
                .foregroundStyle(ModalDesignTokens.coinGradient)
            
            Text(amount)
                .font(.system(size: size.fontSize, weight: .bold))
                .foregroundColor(Color("fontGray"))
        }
    }
}

// MARK: - Modern Text Field

struct ModernTextField: View {
    let placeholder: String
    @Binding var text: String
    @FocusState.Binding var isFocused: Bool
    var minHeight: CGFloat = 120
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty && !isFocused {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            }
            
            TextEditor(text: $text)
                .focused($isFocused)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .scrollContentBackground(.hidden)
                .foregroundColor(Color("fontGray"))
        }
        .frame(minHeight: minHeight)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isFocused ? Color(hex: "667eea") : Color.gray.opacity(0.2),
                            lineWidth: isFocused ? 2 : 1
                        )
                )
        )
        .animation(.easeOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Modern Toggle

struct ModernToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("fontGray").opacity(0.8))
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "667eea")))
                .labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview("Design System") {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        
        VStack(spacing: 20) {
            ModernCard {
                VStack(spacing: 16) {
                    GradientHeader(title: "モダンデザイン", showCloseButton: false)
                    
                    CoinDisplay(amount: "15,000", size: .large)
                    
                    PrimaryActionButton(title: "購入する", icon: "cart.fill") {}
                    
                    SecondaryActionButton(title: "キャンセル") {}
                }
            }
            .frame(width: 320)
            
            BadgeView(text: "人気No.1", color: .red)
        }
    }
}
