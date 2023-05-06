//
//  Home.swift
//  SwiftUI_GooeyCellLiquidAnimation
//
//  Created by パク on 2023/05/05.
//

import SwiftUI

struct Home: View {

    @State var promotions: [Promotion] = [
        .init(name: "TripAdvisor", title: "Your saved search to Vienna", subTitle: placeholderText, logo: "Logo 1"),
        .init(name: "Figma", title: "Figma @mentions are here!", subTitle: placeholderText, logo: "Logo 2"),
        .init(name: "Product Hunt Daily", title: "Must-have Chrome Extensions", subTitle: placeholderText, logo: "Logo 3"),
        .init(name: "invision", title: "First interview with a designer I admire", subTitle: placeholderText, logo: "Logo 4"),
        .init(name: "Pinterest", title: "You’ve got 18 new ideas waiting for you!", subTitle: placeholderText, logo: "Logo 5"),
    ]

    var body: some View {

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                HeaderView()
                    .padding(15)

                ForEach(promotions) { promotion in
                    GooeyCell(promotion: promotion) {

                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Color("BG")
                .ignoresSafeArea()
        )
    }

    @ViewBuilder
    func HeaderView() -> some View {
        HStack {
            Text("Promotion")
                .font(.system(size: 38))
                .fontWeight(.medium)
                .foregroundColor(Color("Green"))
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {

            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(Color("Green"))
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct GooeyCell: View {
    var promotion: Promotion

    var onDelete: () -> Void

    // Animation Properties
    @State var offsetX: CGFloat = 0
    @State var cardOffsetX: CGFloat = 0

    @State var finishAnimation: Bool = false
    var body: some View {
        ZStack(alignment: .trailing) {

            LiquidCanvasView()

            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(promotion.logo)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 22, height: 22)

                        Text(promotion.name)
                            .font(.callout)
                            .fontWeight(.semibold)
                    }

                    Text(promotion.title)
                        .foregroundColor(.black.opacity(0.8))
                    Text(promotion.subTitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .lineLimit(1)

                Spacer()

                Text("29 OCT")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("Green").opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(.white.opacity(0.7))
            )
            .padding(.horizontal, 15)
            .offset(x: cardOffsetX)
            .gesture(
                DragGesture()
                    .onChanged({ value in

                        // ← 左方向のみDragを有効にする
                        var translation = value.translation.width
                        translation = (translation > 0 ? 0 : translation)

                      //  translation = (-translation < cardWidth ? translation : -cardWidth)
                        offsetX = translation
                        cardOffsetX = offsetX
                    }).onEnded({ value in

                        if -value.translation.width > (screenSize().width * 0.6) {
                            // 左半分以上 Swipeした場合、
                            //振動させる
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            finishAnimation = true

                            // Moving Card Outside of Screen.
                            withAnimation(.easeInOut(duration: 0.3)) {
                                cardOffsetX = -screenSize().width
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                onDelete()
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                offsetX = .zero
                                cardOffsetX = .zero
                            }
                        }
                    })
            )
        }
    }

    @ViewBuilder
    func LiquidCanvasView() -> some View {
        Canvas { context, size in
            context.addFilter(.alphaThreshold(min: 0.5, color: Color("Green")))
            context.addFilter(.blur(radius: 5))

            context.drawLayer { layer in
                if let resolvedView = context.resolveSymbol(id: 1) {
                    layer.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                }
            }
        } symbols: {
            GooeyView()
                .tag(1)
        }
        // 丸い背景の上に [x] アイコンを載せる
        .overlay(alignment: .trailing) {

            let cellWidth = screenSize().width * 0.8
            let scale = offsetX / cellWidth

            Image(systemName: "xmark")
                .fontWeight(.semibold)
                .foregroundColor(.white)
                // xボタンを丸の真ん中にするために 8ずらす
                .offset(x: 8)
                .frame(width: 42, height: 42)
                .offset(x: 42)
                // 42隠した分、scale (0 ~ 1) * 42 で丸いやつを正常な位置にoffsetさせる
                .offset(x: scale * 42)
                .offset(x: offsetX * 0.2)

                // MARK: 左画面外へ xを飛ばす処理
                // 左へスケールを小さくさせる
                .scaleEffect(finishAnimation ? 0.1 : 1, anchor: .leading)
                // drag半分以上 onEndedした場合、[x] を左画面の外へ飛ばす
                .offset(x: finishAnimation ? -screenSize().width : 0)
                // [x]を 右から左の恥まで いい感じにanimationさせるために "Shape"イメージと分ける
                .animation(.interactiveSpring(response: 0.6, dampingFraction: 1, blendDuration: 1), value: finishAnimation)

        }

    }

    @ViewBuilder
    func GooeyView() -> some View {

        let cellWidth = screenSize().width * 0.8
        let scale = finishAnimation ? 0 : offsetX / cellWidth

        Image("Shape")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            .scaleEffect(x: -scale, anchor: .trailing)
            .animation(.interactiveSpring(), value: finishAnimation)
            .overlay(alignment: .trailing, content: {
                Circle()
                    .frame(width: 42, height: 42)
                    // 丸いやつを画面の右端に隠しておく
                    .offset(x: 42)
                    // 42隠した分、scale (0 ~ 1) * 42 で丸いやつを正常な位置にoffsetさせる
                    .offset(x: scale * 42)
                    .offset(x: offsetX * 0.2)

                    // MARK: 左画面外へ Circleを飛ばす処理
                     // 左へスケールを小さくさせる
                    .scaleEffect(finishAnimation ? 0.1 : 1, anchor: .leading)
                    // drag半分以上 onEndedした場合、丸い背景を左画面の外へ飛ばす
                    .offset(x: finishAnimation ? -screenSize().width : 0)

                    // 丸い背景を 右から左の恥まで いい感じにanimationさせるために "Shape"イメージと分ける
                    .animation(.interactiveSpring(response: 0.6, dampingFraction: 1, blendDuration: 1), value: finishAnimation)
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
            .offset(x: 8)
    }
}
