//
//  GIFImageView.swift
//  beta
//
//  Created by Kevin Du on 9/11/25.
//
// File: GIFImageView.swift
import SwiftUI

public struct GIFImageView: UIViewRepresentable {
  public let name: String
  public var scale: CGFloat = 1
  public var offset: UnitPoint = .zero
  @Binding public var isPlaying: Bool  // 外部控制开始/暂停
  public var playOnce: Bool = true  // 每轮播完自动暂停

  // MARK: - Coordinator

  public class Coordinator: NSObject {
    weak var imageView: UIImageView?
    var frames: [UIImage] = []
    var frameDurations: [Double] = []
    var firstFrame: UIImage?
    var lastFrame: UIImage?

    private(set) var currentIndex: Int = 0
    private var accumulator: Double = 0

    private var displayLink: CADisplayLink?
    private(set) var isRunning: Bool = false

    // 由 representable 注入，用于回写绑定值
    var updateIsPlaying: ((Bool) -> Void)?
    var playOnce: Bool = true

    @MainActor func configure(
      imageView: UIImageView,
      frames: [UIImage],
      durations: [Double],
      playOnce: Bool
    ) {
      self.imageView = imageView
      self.frames = frames
      self.frameDurations = durations
      self.firstFrame = frames.first
      self.lastFrame = frames.last
      self.playOnce = playOnce

      resetToFirstFrame()
    }

    @MainActor func resetToFirstFrame() {
      currentIndex = 0
      accumulator = 0
      imageView?.image = firstFrame
    }

    @MainActor func start(fromBeginning: Bool) {
      guard !frames.isEmpty else { return }
      if fromBeginning { resetToFirstFrame() }
      guard !isRunning else { return }

      if displayLink == nil {
        let link = CADisplayLink(target: self, selector: #selector(step(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
      }
      isRunning = true
    }

    // 停止播放；showLastFrame=true 时复位到“最后一帧”
    @MainActor func stop(showLastFrame: Bool) {
      displayLink?.invalidate()
      displayLink = nil
      isRunning = false
      accumulator = 0
      if showLastFrame, let last = lastFrame {
        imageView?.image = last
      }
    }

    @MainActor @objc private func step(_ link: CADisplayLink) {
      guard isRunning, !frames.isEmpty, currentIndex < frames.count else { return }

      accumulator += link.duration
      let currentFrameDuration = frameDurations[currentIndex]

      if accumulator >= currentFrameDuration {
        accumulator -= currentFrameDuration
        currentIndex += 1

        if currentIndex >= frames.count {
          // 完成一轮
          if playOnce {
            // 自动暂停并复位到最后一帧
            stop(showLastFrame: true)
            updateIsPlaying?(false)  // 回写绑定：播放结束 -> false
            return
          } else {
            // 循环：回到首帧
            currentIndex = 0
          }
        }

        imageView?.image = frames[currentIndex]
      }
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator()
  }

  // MARK: - UIViewRepresentable

  public func makeUIView(context: Context) -> UIView {
    let container = UIView()

    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false

    container.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      imageView.topAnchor.constraint(equalTo: container.topAnchor),
      imageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])

    // 如果需要初始缩放，保留此行
    imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
      .translatedBy(x: offset.x, y: offset.y)

    let coord = context.coordinator
    coord.imageView = imageView
    coord.updateIsPlaying = { playing in
      if isPlaying != playing {
        DispatchQueue.main.async {
          self.isPlaying = playing
        }
      }
    }

    // 载入 GIF，解析帧与时长
    if let asset = NSDataAsset(name: name) {
      loadGIF(from: asset.data, into: imageView, coordinator: coord)
    } else if let url = Bundle.main.url(forResource: name, withExtension: nil),
      let data = try? Data(contentsOf: url)
    {
      loadGIF(from: data, into: imageView, coordinator: coord)
    }

    // 初始播放
    if isPlaying {
      coord.start(fromBeginning: true)
    }

    return container
  }

  public func updateUIView(_ uiView: UIView, context: Context) {
    let coord = context.coordinator
    coord.playOnce = playOnce

    if isPlaying {
      // 每次从暂停 -> 播放，均从第一帧开始
      coord.start(fromBeginning: true)
    } else {
      // 停止时复位到“最后一帧”
      coord.stop(showLastFrame: true)
    }
  }

  // MARK: - Helpers

  private func loadGIF(
    from data: Data,
    into imageView: UIImageView,
    coordinator: Coordinator
  ) {
    guard let src = CGImageSourceCreateWithData(data as CFData, nil) else { return }
    let count = CGImageSourceGetCount(src)
    var frames: [UIImage] = []
    var durations: [Double] = []
    frames.reserveCapacity(count)
    durations.reserveCapacity(count)

    for i in 0..<count {
      guard let cg = CGImageSourceCreateImageAtIndex(src, i, nil) else { continue }
      let frame = UIImage(cgImage: cg, scale: UIScreen.main.scale, orientation: .up)
      frames.append(frame)
      durations.append(gifFrameDuration(from: src, index: i))
    }

    if durations.allSatisfy({ $0 <= 0 }) {
      durations = Array(repeating: 0.1, count: durations.count)
    }

    coordinator.configure(
      imageView: imageView,
      frames: frames,
      durations: durations,
      playOnce: playOnce
    )
  }

  // 读取单帧时长：优先 UnclampedDelayTime，其次 DelayTime，设置下限避免 0
  private func gifFrameDuration(from source: CGImageSource, index: Int) -> Double {
    let defaultFrameDuration = 0.1
    guard let props = CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any],
      let gifDict = props[kCGImagePropertyGIFDictionary] as? [CFString: Any]
    else {
      return defaultFrameDuration
    }
    let unclamped = gifDict[kCGImagePropertyGIFUnclampedDelayTime] as? Double
    let clamped = gifDict[kCGImagePropertyGIFDelayTime] as? Double
    let val = (unclamped ?? clamped) ?? defaultFrameDuration
    return max(val, 0.02)  // 常见播放器的最小时长
  }
}
