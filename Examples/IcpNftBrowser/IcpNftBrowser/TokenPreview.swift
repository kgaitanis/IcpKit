//
//  TokenPreview.swift
//  IcpNftBrowser
//
//  Created by Konstantinos Gaitanis on 02.09.24.
//

import SwiftUI
import DAB

struct TokenPreview: View {
    let token: ICPToken
    
    var body: some View {
        Card(
            image: token.logo,
            title: token.name,
            description: nil,
            tag: token.standard.description
        )
    }
}

#Preview {
    TokenPreview(token: PreviewModels.mockToken)
}

extension ICPTokenStandard: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dip20: return "DIP20"
        case .xtc: return "XTC"
        case .wIcp: return "WICP"
        case .ext: return "EXT"
        case .icp: return "ICP"
        case .rosetta: return "Rosetta"
        case .icrc1: return "ICRC1"
        case .icrc2: return "ICRC2"
        case .drc20: return "DRC20"
        }
    }
}
