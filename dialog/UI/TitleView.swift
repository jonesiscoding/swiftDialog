//
//  TitleView.swift
//  Dialog
//
//  Created by Reardon, Bart (IM&T, Yarralumla) on 19/3/21.
//

import Foundation
import SwiftUI

struct TitleView: View {
    
    var TitleViewOption: String = CLOptionText(OptionName: CLOptions.titleOption, DefaultValue: appvars.titleDefault)

    var body: some View {
        VStack {
            Text(TitleViewOption)
                .bold()
                .font(.system(size: appvars.titleFontSize))
        }
        .offset(y: -15) // shift the title up a notch
        //.border(Color.purple) //debuging
    }
}
