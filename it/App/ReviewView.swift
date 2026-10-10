//
//  ReviewView.swift
//  osimono
//
//  Created by Apple on 2025/07/08.
//

import SwiftUI
import FirebaseAnalytics

enum ReviewPromptSource: String {
    case normalClear = "normal_clear"
    case storyVictory = "story_victory"
}

final class ReviewRequestManager {
    static let shared = ReviewRequestManager()

    private enum Key {
        static let firstEligibleUseDate = "review.firstEligibleUseDate"
        static let completedQuizCount = "review.completedQuizCount"
        static let lastRequestedVersion = "review.lastRequestedVersion"
        static let requestDates = "review.requestDates"
    }

    private let defaults: UserDefaults
    private let minimumUseInterval: TimeInterval = 7 * 24 * 60 * 60
    private let requestCooldown: TimeInterval = 120 * 24 * 60 * 60
    private let yearlyInterval: TimeInterval = 365 * 24 * 60 * 60

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if defaults.object(forKey: Key.firstEligibleUseDate) == nil {
            defaults.set(Date(), forKey: Key.firstEligibleUseDate)
        }
    }

    func recordQuizCompletion(satisfactionEvent: Bool, now: Date = Date()) -> Bool {
        let completedCount = defaults.integer(forKey: Key.completedQuizCount) + 1
        defaults.set(completedCount, forKey: Key.completedQuizCount)

        guard satisfactionEvent,
              completedCount >= 3,
              hasUsedAppLongEnough(at: now),
              hasNotRequestedCurrentVersion,
              hasPassedCooldown(at: now),
              recentRequestDates(at: now).count < 3 else {
            return false
        }

        return true
    }

    func markReviewRequested(source: ReviewPromptSource, now: Date = Date()) {
        var requestDates = recentRequestDates(at: now)
        requestDates.append(now)
        defaults.set(requestDates, forKey: Key.requestDates)
        defaults.set(currentVersion, forKey: Key.lastRequestedVersion)

        Analytics.logEvent("review_prompt_requested", parameters: [
            "source": source.rawValue,
            "app_version": currentVersion,
            "completed_quiz_count": defaults.integer(forKey: Key.completedQuizCount),
            "days_since_first_use": daysSinceFirstUse(at: now)
        ])
    }

    private func hasUsedAppLongEnough(at date: Date) -> Bool {
        guard let firstUseDate = defaults.object(forKey: Key.firstEligibleUseDate) as? Date else {
            return false
        }

        return date.timeIntervalSince(firstUseDate) >= minimumUseInterval
    }

    private var hasNotRequestedCurrentVersion: Bool {
        defaults.string(forKey: Key.lastRequestedVersion) != currentVersion
    }

    private func hasPassedCooldown(at date: Date) -> Bool {
        guard let lastRequestDate = recentRequestDates(at: date).max() else {
            return true
        }

        return date.timeIntervalSince(lastRequestDate) >= requestCooldown
    }

    private func recentRequestDates(at date: Date) -> [Date] {
        let dates = defaults.array(forKey: Key.requestDates) as? [Date] ?? []
        return dates.filter { date.timeIntervalSince($0) < yearlyInterval }
    }

    private func daysSinceFirstUse(at date: Date) -> Int {
        guard let firstUseDate = defaults.object(forKey: Key.firstEligibleUseDate) as? Date else {
            return 0
        }

        return max(0, Calendar.current.dateComponents([.day], from: firstUseDate, to: date).day ?? 0)
    }

    private var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "unknown"
    }
}

struct ReviewView: View {
    @ObservedObject var authManager = AuthManager.shared
    @Binding var isPresented: Bool
    @Binding var helpFlag: Bool
    @State var toggle = false
    @State private var text: String = ""
    @State private var showAlert = false
    @State private var activeAlert: ActiveAlert?
    @State private var animateIn = false
    
    enum ActiveAlert: Identifiable {
        case satisfied, dissatisfied
        
        var id: Int {
            hashValue
        }
    }
    
    var body: some View {
        ZStack {
            // 背景のブラー効果
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    closeModal()
                }
            
            VStack(spacing: 0) {
                // ヘッダー部分
                VStack(spacing: 16) {
                    // アイコン
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 70, height: 70)
                        
                        Image(systemName: "heart.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .scaleEffect(animateIn ? 1.0 : 0.8)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateIn)
                    
                    // タイトル
                    Text("フィードバックをお聞かせください")
                        .font(.system(size: isSmallDevice() ? 20 : 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: animateIn)
                    
                    Text("あなたの体験を教えてください")
                        .font(.system(size: isSmallDevice() ? 14 : 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .opacity(animateIn ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5).delay(0.3), value: animateIn)
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)
                
                // 選択肢ボタン
                VStack(spacing: 20) {
                    // 満足ボタン
                    Button(action: {
                        generateHapticFeedback()
                        optOutIfRequested()
                        activeAlert = .satisfied
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.green.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "face.smiling")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("満足")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("アプリの使い心地が良い")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(animateIn ? 1.0 : 0.9)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.4).delay(0.4), value: animateIn)
                    
                    // 不満ボタン
                    Button(action: {
                        generateHapticFeedback()
                        optOutIfRequested()
                        activeAlert = .dissatisfied
                    }) {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "face.dashed")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("不満")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.primary)
                                
                                Text("改善してほしい点がある")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(animateIn ? 1.0 : 0.9)
                    .opacity(animateIn ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.4).delay(0.5), value: animateIn)
                }
                .padding(.top, 30)
                .padding(.horizontal, 20)
                
                // トグル設定
                VStack(spacing: 12) {
                    Divider()
                        .padding(.horizontal, 20)
                    
                    HStack {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        
                        Text("今後は表示しない")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Toggle("", isOn: $toggle)
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .scaleEffect(0.9)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                .opacity(animateIn ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.4).delay(0.6), value: animateIn)
            }
            .frame(width: isSmallDevice() ? 340 : 380)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemGray6))
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            )
            .scaleEffect(animateIn ? 1.0 : 0.9)
            .opacity(animateIn ? 1.0 : 0.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: animateIn)
            
            // 閉じるボタン
            VStack {
                HStack {
                    Spacer()
                    Button(action: closeModal) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.1))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                        }
                    }
                    .offset(x: -10, y: 10)
                }
                Spacer()
            }
        }
        .alert(item: $activeAlert) { alert in
            switch alert {
            case .satisfied:
                return Alert(
                    title: Text("ありがとうございます！！"),
                    message: Text("いただいた回答を今後のサービス改善に活用します🙇‍♂️"),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                    }
                )
            case .dissatisfied:
                return Alert(
                    title: Text("回答ありがとうございます！"),
                    message: Text("サービス向上のためご意見お聞かせください🙇‍♂️"),
                    dismissButton: .default(Text("OK")) {
                        helpFlag = true
                        isPresented = false
                    }
                )
            }
        }
        .onAppear {
            withAnimation {
                animateIn = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // print(store.productList)
            }
        }
    }
    
    private func closeModal() {
        generateHapticFeedback()
        optOutIfRequested()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            animateIn = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }

    private func optOutIfRequested() {
        guard toggle else { return }
        authManager.optOutOfCurrentFeedbackPrompts()
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
    ReviewView(isPresented: .constant(true), helpFlag: .constant(true))
}
