//
//  ContentView.swift
//  SwiftUI_GooeyCellLiquidAnimation
//
//  Created by パク on 2023/05/05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View {
    func screenSize() -> CGSize {
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .zero }
        return window.screen.bounds.size
    }
}
