import SwiftUI

struct SizePreference: PreferenceKey {
    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
        value = value ?? nextValue()
    }
}

fileprivate struct FlexibleText: View {
    var base: Text
    var font: (CGFloat) -> Font
    @State private var widthAt100Points: CGFloat?
    @State private var height: CGFloat?
    
    var body: some View {
        GeometryReader { proxy in
            self.base
                .fixedSize()
                .font(self.font(100 * proxy.size.width/(self.widthAt100Points ?? 1)))
                .overlay(
                    GeometryReader { proxy in
                        Color.clear.preference(key: SizePreference.self, value: proxy.size)
                    }.onPreferenceChange(SizePreference.self) { size in
                        self.height = size?.height
                    })
                .border(Color.blue)
                .background(
                    self.base
                        .fixedSize()
                        .font(self.font(100))
                        .overlay(GeometryReader { proxy in
                            Color.clear.preference(key: SizePreference.self, value: proxy.size)
                        }).onPreferenceChange(SizePreference.self) { size in
                            self.widthAt100Points = size?.width
                    }.hidden()
                )
        }
        .frame(height: self.height)
        .border(Color.red)
    }
}

extension Text {
    func flexible(_ font: @escaping (CGFloat) -> Font) -> some View {
        FlexibleText(base: self, font: font)
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello, World!").flexible({ size in
            Font.system(size: size, weight: .thin)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
