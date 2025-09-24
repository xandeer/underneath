//
//  File.swift
//  Underneath
//
//  Created by Kevin Du on 7/17/25.
//

#if canImport(UIKit)
  import SwiftUI

  extension View {
    #if !os(watchOS)
      public func snapshot() -> UIImage? {
        let r = ImageRenderer(content: self)
        r.scale = UIScreen.main.scale
        return r.uiImage
      }
    #endif

    @ViewBuilder
    public func `if`<Content: View>(
      _ condition: Bool,
      transform: (Self) -> Content
    ) -> some View {
      if condition {
        transform(self)
      } else {
        self
      }
    }

    @ViewBuilder
    public func `if`<TrueContent: View, FalseContent: View>(
      _ condition: Bool,
      then: (Self) -> TrueContent,
      else els: (Self) -> FalseContent
    ) -> some View {
      if condition {
        then(self)
      } else {
        els(self)
      }
    }
  }
#endif

extension View {
  public func frameSize(_ size: CGFloat) -> some View {
    frame(width: size, height: size)
  }

  public func greedyWidth() -> some View {
    frame(maxWidth: .infinity)
  }

  public func greedyHeight() -> some View {
    frame(maxHeight: .infinity)
  }

  public func greedySize() -> some View {
    greedyWidth().greedyHeight()
  }

  public func largeRounded() -> some View {
    clipShape(RoundedRectangle.large)
  }

  public func fullTap(_ animation: Animation? = .default, perform: @escaping () -> Void) -> some View {
    contentShape(Rectangle())
      .onTapGesture {
        withAnimation(animation) {
          perform()
        }
      }
  }

  public func clearGlassIfAvailable<S: Shape, Content: View>(
    interactive: Bool = false,
    tint: Color = .clear,
    in shape: S = RoundedRectangle.large,
    @ViewBuilder notAvailable: (Self) -> Content = { $0 as Content }
  ) -> some View {
    glassEffectIfAvailable(.clear, interactive: interactive, tint: tint, in: shape, notAvailable: notAvailable)
  }

  public func regularGlassIfAvailable<S: Shape, Content: View>(
    interactive: Bool = false,
    tint: Color = .clear,
    in shape: S = RoundedRectangle.large,
    @ViewBuilder notAvailable: (Self) -> Content = { $0 as Content }
  ) -> some View {
    glassEffectIfAvailable(.regular, interactive: interactive, tint: tint, in: shape, notAvailable: notAvailable)
  }

  public func glassEffectIfAvailable<S: Shape, Content: View>(
    _ style: GlassStyle,
    interactive: Bool = false,
    tint: Color = .clear,
    in shape: S = RoundedRectangle.large,
    @ViewBuilder notAvailable: (Self) -> Content = { $0 as Content }
  ) -> some View {
    Group {
      if #available(iOS 26, watchOS 26, tvOS 26, macOS 26, *) {
        glassEffect(style.effect.interactive(interactive).tint(tint), in: shape)
      } else {
        notAvailable(self)
      }
    }
  }
}

public enum GlassStyle {
  case clear, regular
}

extension GlassStyle {
  @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
  @available(visionOS, unavailable)
  public var effect: Glass {
    switch self {
    case .clear:
      return .clear
    case .regular:
      return .regular
    }
  }
}

extension RoundedRectangle {
  public static let large = RoundedRectangle(cornerRadius: 20)
}
