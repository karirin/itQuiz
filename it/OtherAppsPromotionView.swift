//
//  OtherAppsPromotionView.swift
//  it
//
//  Created by Apple on 2025/02/16.
//

import SwiftUI

struct OtherAppsPromotionView: View {
    @State private var selectedApp: UUID? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // ヘッダー部分
                VStack(spacing: 8) {
                    Text("他のおすすめアプリ")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 20)
                
                // アプリリスト
                ForEach(OtherApp.allApps) { app in
                    AppCardView(app: app, selectedApp: $selectedApp)
                        .scaleEffect(selectedApp == app.id ? 0.98 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: selectedApp)
                }
            }
            .padding(.horizontal, 20)
//            .padding(.bottom, 10)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("Color2").opacity(0.3),
                    Color("Color2")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct AppCardView: View {
    let app: OtherApp
    @Binding var selectedApp: UUID?
    
    var body: some View {
        Link(destination: URL(string: app.appStoreLink)!) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    // アプリアイコン
                    AsyncImage(url: URL(string: app.iconURL ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(app.name)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    // アプリ情報
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(app.name)
                                .font(.system(size:14))
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            
                            Text("無料")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        Text(app.description2)
                            .font(.system(size:14))
                            .lineLimit(4)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    // 矢印アイコン
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .padding(8)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            selectedApp = app.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedApp = nil
            }
        }
    }
}

// OtherAppモデルの拡張（必要に応じて）
extension OtherApp {
    var iconURL: String? {
        // App Storeから動的にアイコンを取得する場合のURL
        return nil
    }
    
    var rating: Double? {
        // レーティング情報（実際のデータに応じて）
        return 4.5
    }
}

#Preview {
    OtherAppsPromotionView()
}
