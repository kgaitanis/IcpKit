//
//  NftPreview.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 29.08.24.
//

import SwiftUI
import DAB

struct NftPreview: View {
    let nft: ICPNftDetails
    
    var body: some View {
        Card(
            image: nft.imageUrl,
            title: nft.name,
            description: nft.index.description,
            tag: nil
        )
    }
}

#Preview {
    NftPreview(nft: PreviewModels.mockNft)
}
