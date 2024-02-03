//
//  RunTaskToolbarRunItem.swift
//  CodeEdit
//
//  Created by Khan Winter on 2/2/24.
//

import Foundation
import SwiftUI

struct RunTaskToolbarRunItem: View {
    @State private var showHoverIndicator: Bool = false

    var body: some View {
        Button {

        } label: {
            label
        }
        .onHover { isHovering in
            showHoverIndicator = isHovering
        }
    }

    @ViewBuilder var label: some View {
        HStack(spacing: 0) {
            Image(systemName: "chevron.down") // Placeholder so it's got even spacing horizontally
                .imageScale(.small)
                .font(.system(size: 8, weight: .regular))
                .opacity(0.0)
            Image(systemName: "play.fill")
                .imageScale(.large)
            VStack(spacing: 0) {
                Spacer()
                Image(systemName: "chevron.down")
                    .imageScale(.small)
                    .font(.system(size: 8, weight: .bold))
                    .opacity(showHoverIndicator ? 1.0 : 0.0)
            }
        }
    }
}

#Preview {
    RunTaskToolbarRunItem()
}
