import SwiftUI

struct CustomTextField: View {
    let icon: String
    let placeHolder: String
    @Binding var text: String

    @State private var width = CGFloat.zero
    @State private var labelWidth = CGFloat.zero

    let rounded1: CGFloat
    let rounded2: CGFloat

    var body: some View {
        HStack {
            TextField("", text: $text)
                .foregroundColor(.black)
                .font(GilroyFont(isBold: true, size: 20))
                .keyboardType(.default)
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 0))
                .overlay {
                    GeometryReader { geo in
                        Color.clear.onAppear {
                            width = geo.size.width
                        }
                    }
                }
        }
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .trim(from: 0, to: rounded1)
                    .stroke(.gray, lineWidth: 1)

                RoundedRectangle(cornerRadius: 12)
                    .trim(from: rounded2 + (0.44 * (labelWidth / width)), to: 1)
                    .stroke(.gray, lineWidth: 1)

                Text(placeHolder)
                    .foregroundColor(.black)
                    .overlay {
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                labelWidth = geo.size.width
                            }
                        }
                    }
                    .padding(2)
                    .font(GilroyFont(isBold: true, size: 13))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .offset(x: 20, y: -10)
            }
        }
    }
}

func GilroyFont(isBold: Bool = false, size: CGFloat) -> Font {
    if isBold {
        return Font.custom("Gilroy-ExtraBold", size: size)
    }else {
        return Font.custom("Gilroy-Light", size: size)
    }
}
