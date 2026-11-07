//
//  RemoteImage.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 30.08.24.
//

import SwiftUI
import UIKit
import SVGView

struct RemoteImage: View {
    let url: URL?
    @State var error: Bool = false
    
    init(_ url: URL?) {
        self.url = url
    }
    
    
    var body: some View {
        if error {
            Color.red
        } else if let url = url {
            MiniWebView(url: url, error: $error)
                .scaledToFill()
        } else {
            Image(uiImage: .remove)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    RemoteImage(PreviewModels.mockSvgUrl)
}
