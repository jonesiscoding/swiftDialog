//
//  IconView.swift
//  Dialog
//
//  Created by Reardon, Bart (IM&T, Yarralumla) on 19/3/21.
//

import Foundation
import SwiftUI


struct IconView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var messageUserImagePath: String = CLOptionText(OptionName: CLOptions.iconOption, DefaultValue: "default")
    var logoWidth: CGFloat = appvars.imageWidth
    var logoHeight: CGFloat  = appvars.imageHeight
    var imgFromURL: Bool = false
    var imgFromAPP: Bool = false
    var imgXOffset: CGFloat = 0//25
    
    var builtInIconName: String = ""
    var builtInIconColour: Color = Color.primary
    var builtInIconSecondaryColour: Color = Color.secondary
    var builtInIconFill: String = ""
    var builtInIconPresent: Bool = false
    var builtInIconWeight = Font.Weight.thin
    
    var iconRenderingMode = Image.TemplateRenderingMode.original
    
    var sfSymbolName: String = ""
    var sfSymbolWeight = Font.Weight.thin
    var sfSymbolColour1: Color = Color.primary
    var sfSymbolColour2: Color = Color.secondary
    var sfSymbolPresent: Bool = false
    
    var sfGradientPresent: Bool = false
    
    /*
    func isValidColourHex(_ hexvalue: String) -> Bool {
        let hexRegEx = "^#([a-fA-F0-9]{6})$"
        let hexPred = NSPredicate(format:"SELF MATCHES %@", hexRegEx)
        return hexPred.evaluate(with: hexvalue)
    }
    */
    
    init() {        
        logoWidth = appvars.imageWidth
        logoHeight = appvars.imageHeight
        
        
        // fullscreen runs on a dark background so invert the default icon colour for info and default
        // also set the icon offset to 0
        if CLOptionPresent(OptionName: CLOptions.fullScreenWindow) {
            builtInIconColour = Color.white
            imgXOffset = 0
            
            //logoWidth = logoWidth * 5
            //logoHeight = logoHeight * 5
        }
        
        if messageUserImagePath.starts(with: "http") {
            imgFromURL = true
        }
        
        if messageUserImagePath.hasSuffix(".app") || messageUserImagePath.hasSuffix("prefPane") {
            imgFromAPP = true
        }
        
        if messageUserImagePath.hasPrefix("SF=") {
            //print("sf present")
            sfSymbolPresent = true
            builtInIconPresent = true
            
            var SFValues = messageUserImagePath.components(separatedBy: ",")
            SFValues = SFValues.map { $0.trimmingCharacters(in: .whitespaces) } // trim out any whitespace from the values if there were spaces before after the comma
            
            for value in SFValues {
                // split by =
                let item = value.components(separatedBy: "=")

                if item[0] == "SF" {
                    builtInIconName = item[1]
                }
                if item[0] == "weight" {
                    builtInIconWeight = textToFontWeight(item[1])
                }
                if item[0].hasPrefix("colour") || item[0].hasPrefix("color") {
                    if item[1] == "auto" {
                        // detecting sf symbol properties seems to be annoying, at least in swiftui 2
                        // this is a bit of a workaround in that we let the user determine if they want the multicolour SF symbol
                        // or a standard template style. sefault is template. "auto" will use the built in SF Symbol colours
                        iconRenderingMode = Image.TemplateRenderingMode.original
                    } else { //check to see if it's in the right length and only contains the right characters
                        
                        iconRenderingMode = Image.TemplateRenderingMode.template // switches to monochrome which allows us to tint the sf symbol
                                                
                        if item[0].hasSuffix("2") {
                            sfGradientPresent = true
                            builtInIconSecondaryColour = stringToColour(item[1])
                        } else {
                            builtInIconColour = stringToColour(item[1])
                        }
                    //} else {
                        //quitDialog(exitCode: 14, exitMessage: "Hex value for colour is not valid: \(item[1])")
                        //print("Hex value for colour is not valid: \(item[1])")
                    }
                } else {
                   iconRenderingMode = Image.TemplateRenderingMode.template
               }
            }
        }
        
        if CLOptionPresent(OptionName: CLOptions.warningIcon) || messageUserImagePath == "warning" {
            builtInIconName = "exclamationmark.octagon.fill"
            builtInIconFill = "octagon.fill" //does not have multicolour sf symbol so we have to make out own using a fill layer
            builtInIconColour = Color.red
            iconRenderingMode = Image.TemplateRenderingMode.template //force monochrome
            builtInIconPresent = true
        } else if CLOptionPresent(OptionName: CLOptions.cautionIcon) || messageUserImagePath == "caution" {
            builtInIconName = "exclamationmark.triangle.fill"  // yay multicolour sf symbol
            //builtInIconFill = "triangle.fill"
            //builtInIconColour = Color.yellow
            builtInIconPresent = true
        } else if CLOptionPresent(OptionName: CLOptions.infoIcon) || messageUserImagePath == "info" {
            builtInIconName = "person.fill.questionmark"
            builtInIconPresent = true
        } else if messageUserImagePath == "default" {
            builtInIconName = "message.circle.fill"
            iconRenderingMode = Image.TemplateRenderingMode.template //force monochrome
            builtInIconPresent = true
            //builtInIconColour = sfSymbolColour1
            //builtInIconWeight = sfSymbolWeight
        }
        
                
        if !FileManager.default.fileExists(atPath: messageUserImagePath) && !imgFromURL && !imgFromAPP && !builtInIconPresent  {
            quitDialog(exitCode: appvars.exit202.code, exitMessage: "\(appvars.exit202.message) \(messageUserImagePath)")
        }
        
        //print("colour is \(builtInIconColour)")
        
    }
    
    var body: some View {
        ZStack {
            //GeometryReader { icon in
            //HStack {
                if builtInIconPresent {
                    ZStack {
                        if sfGradientPresent {
                            // we need to add this twice - once as a clear version to force the right aspect ratio
                            // and again with the gradien colour we want
                            // the reason for this is gradient by itself is greedy and will consume the entire height and witch of the display area
                            // this causes some SF Symbols like applelogo and applescript to look distorted
                            Image(systemName: builtInIconName)
                                .renderingMode(iconRenderingMode)
                                .resizable()
                                .foregroundColor(.clear)
                                .font(Font.title.weight(builtInIconWeight))
                                
                            LinearGradient(gradient: Gradient(colors: [builtInIconColour, builtInIconSecondaryColour]), startPoint: .top, endPoint: .bottomTrailing)
                            //LinearGradient(gradient: Gradient(colors: [.clear, .clear]), startPoint: .top, endPoint: .bottom)
                                .mask(
                                Image(systemName: builtInIconName)
                                    .renderingMode(iconRenderingMode)
                                    .resizable()
                                    .foregroundColor(builtInIconColour)
                                    .font(Font.title.weight(builtInIconWeight))
                                    //.frame(maxWidth: appvars.imageWidth, maxHeight: appvars.imageHeight)
                                )
                            
                        } else {
                            Image(systemName: builtInIconFill)
                                .resizable()
                                .foregroundColor(Color.white)
                            Image(systemName: builtInIconName)
                                .resizable()
                                .renderingMode(iconRenderingMode)
                                .font(Font.title.weight(builtInIconWeight))
                                .foregroundColor(builtInIconColour)
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .offset(x: imgXOffset)
                    .scaleEffect(0.8)
                    //.overlay(IconOverlayView(), alignment: .bottomTrailing)
                    //.border(Color.green)
                } else if imgFromAPP {
                    Image(nsImage: getAppIcon(appPath: messageUserImagePath))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .scaledToFit()
                            .scaleEffect(0.8)
                            //.offset(x: imgXOffset)
                            //.overlay(IconOverlayView(), alignment: .bottomTrailing)
                            //.border(Color.green)
                } else {
                    let diskImage: NSImage = getImageFromPath(fileImagePath: messageUserImagePath)
                    Image(nsImage: diskImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaledToFit()
                        //.frame(width: self.logoWidth, height: diskImage.size.height*(logoWidth/diskImage.size.width))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        //.offset(x: imgXOffset, y: 8)
                        .scaleEffect(0.8)
                        //.overlay(IconOverlayView(overlayIconWidth: logoWidth/2, overlayIconHeight: diskImage.size.height*(logoWidth/diskImage.size.width)/2), alignment: .bottomTrailing)
                        //.border(Color.green)

                }
            //}
            //}
            IconOverlayView()
                .scaleEffect(0.4, anchor:.bottomTrailing)
                //.offset(x: 10, y: 10)
                //.frame(width: logoWidth/2, height: logoHeight/2)
                //.frame(alignment: .bottomTrailing)
                //.border(Color.green)
        }
        //.overlay(IconOverlayView(), alignment: .topTrailing)
        //.border(Color.green) //debuging
        
    }
}

