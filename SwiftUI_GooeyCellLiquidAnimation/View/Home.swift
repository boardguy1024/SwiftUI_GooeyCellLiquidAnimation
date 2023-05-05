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

    var body: some View {
        ZStack(alignment: .trailing) {

            CanvasView()

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
            .offset(x: offsetX)
            .gesture(
                DragGesture()
                    .onChanged({ value in

                        // ← 左方向のみDragを有効にする
                        var translation = value.translation.width
                        translation = (translation > 0 ? 0 : translation)

                      //  translation = (-translation < cardWidth ? translation : -cardWidth)
                        offsetX = translation
                    }).onEnded({ value in

                        withAnimation(.easeInOut(duration: 0.3)) {
                            offsetX = 0
                        }
                    })
            )
        }
    }

    @ViewBuilder
    func CanvasView() -> some View {
        Canvas { ctx, size in
            ctx.addFilter(.alphaThreshold(min: 0.5, color: Color("Green")))
            ctx.addFilter(.blur(radius: 5))

            ctx.drawLayer { layer in
                if let resolvedView = ctx.resolveSymbol(id: 1) {
                    layer.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                }
            }
        } symbols: {
            GooeyView()
                .tag(1)
        }
    }

    @ViewBuilder
    func GooeyView() -> some View {

        let cellWidth = screenSize().width * 0.8
        let scale = offsetX / cellWidth
        Image("Shape")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 100)
            .scaleEffect(x: -scale, anchor: .trailing)
            .overlay(alignment: .trailing, content: {
                Circle()
                    .frame(width: 42, height: 42)
                    .offset(x: offsetX * 0.2)
            })
            .frame(maxWidth: .infinity, alignment: .trailing)
            .offset(x: 8)
    }
}
