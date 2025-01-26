//
//  VideoWriter.swift
//  MC3
//
//  Created by Dhammiko Dharmawan on 18/07/24.
//

import AVFoundation
import UIKit

class VideoWriter {
    var writer: AVAssetWriter
    var writerInput: AVAssetWriterInput
    var adaptor: AVAssetWriterInputPixelBufferAdaptor
    var frameCount: Int = 0
    var outputURL: URL

    init?(outputURL: URL, frameSize: CGSize) {
        self.outputURL = outputURL
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: .mov)
        } catch {
            print("Error initializing AVAssetWriter: \(error)")
            return nil
        }

        writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: frameSize.width,
            AVVideoHeightKey: frameSize.height,
        ])

        adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: nil)

        writer.add(writerInput)
    }

    func startWriting() {
        if writer.status == .unknown {
            writer.startWriting()
            writer.startSession(atSourceTime: .zero)
        } else {
            print("Writer status is not unknown: \(writer.status.rawValue)")
        }
    }

    func addFrame(_ image: UIImage) {
        guard let pixelBuffer = image.pixelBuffer() else { return }
        if writer.status == .writing && writerInput.isReadyForMoreMediaData {
            let frameTime = CMTime(value: CMTimeValue(frameCount), timescale: 30)
            adaptor.append(pixelBuffer, withPresentationTime: frameTime)
            frameCount += 1
        } else {
        }
    }

    func finishWriting(completion: @escaping () -> Void) {
        guard writer.status == .writing else {
            print("Cannot finish writing, status: \(writer.status)")
            if writer.status == .failed {
                print("Writer error: \(String(describing: writer.error))")
            }
            completion()
            return
        }

        writerInput.markAsFinished()
        writer.finishWriting(completionHandler: completion)
    }
}

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        let width = Int(size.width)
        let height = Int(size.height)
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(buffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)

        context?.translateBy(x: 0, y: CGFloat(height))
        context?.scaleBy(x: 1.0, y: -1.0)

        UIGraphicsPushContext(context!)
        draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        UIGraphicsPopContext()

        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}

