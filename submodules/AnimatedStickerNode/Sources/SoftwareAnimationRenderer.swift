import Foundation
import UIKit
import AsyncDisplayKit
import Display
import SwiftSignalKit
import YuvConversion

final class SoftwareAnimationRenderer: ASDisplayNode, AnimationRenderer {
    private var highlightedContentNode: ASDisplayNode?
    private var highlightedColor: UIColor?
    
    func render(queue: Queue, width: Int, height: Int, bytesPerRow: Int, data: Data, type: AnimationRendererFrameType, completion: @escaping () -> Void) {
        assert(bytesPerRow > 0)
        queue.async { [weak self] in
            switch type {
            case .argb:
                let calculatedBytesPerRow =  DeviceGraphicsContextSettings.shared.bytesPerRow(forWidth: Int(width))
                assert(bytesPerRow == calculatedBytesPerRow)
            case .yuva:
                break
            }
            
            let image = generateImagePixel(CGSize(width: CGFloat(width), height: CGFloat(height)), scale: 1.0, pixelGenerator: { _, pixelData, contextBytesPerRow in
                switch type {
                case .yuva:
                    data.withUnsafeBytes { bytes -> Void in
                        guard let baseAddress = bytes.baseAddress else {
                            return
                        }
                        if bytesPerRow <= 0 || height <= 0 || width <= 0 || bytesPerRow * height > bytes.count {
                            assert(false)
                            return
                        }
                        decodeYUVAToRGBA(baseAddress.assumingMemoryBound(to: UInt8.self), pixelData, Int32(width), Int32(height), Int32(contextBytesPerRow))
                    }
                case .argb:
                    data.withUnsafeBytes { bytes -> Void in
                        guard let baseAddress = bytes.baseAddress else {
                            return
                        }
                        memcpy(pixelData, baseAddress.assumingMemoryBound(to: UInt8.self), bytes.count)
                    }
                }
            })
            
            Queue.mainQueue().async {
                self?.contents = image?.cgImage
                self?.updateHighlightedContentNode()
                completion()
            }
        }
    }
    
    private func updateHighlightedContentNode() {
        guard let highlightedContentNode = self.highlightedContentNode, let highlightedColor = self.highlightedColor, let contents = self.contents, CFGetTypeID(contents as CFTypeRef) == CGImage.typeID else {
            return
        }
        (highlightedContentNode.view as! UIImageView).image = UIImage(cgImage: contents as! CGImage).withRenderingMode(.alwaysTemplate)
        highlightedContentNode.tintColor = highlightedColor
    }
    
    func setOverlayColor(_ color: UIColor?, animated: Bool) {
        var updated = false
        if let current = self.highlightedColor, let color = color {
            updated = !current.isEqual(color)
        } else if (self.highlightedColor != nil) != (color != nil) {
            updated = true
        }
        
        if !updated {
            return
        }
        
        self.highlightedColor = color
        
        if let _ = color {
            if let highlightedContentNode = self.highlightedContentNode {
                highlightedContentNode.alpha = 1.0
            } else {
                let highlightedContentNode = ASDisplayNode(viewBlock: {
                    return UIImageView()
                }, didLoad: nil)
                highlightedContentNode.displaysAsynchronously = false
                
                self.highlightedContentNode = highlightedContentNode
                highlightedContentNode.frame = self.bounds
                self.addSubnode(highlightedContentNode)
            }
            self.updateHighlightedContentNode()
        } else if let highlightedContentNode = self.highlightedContentNode {
            highlightedContentNode.alpha = 0.0
            highlightedContentNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.3, completion: { [weak self] completed in
                guard let strongSelf = self, completed else {
                    return
                }
                strongSelf.highlightedContentNode?.removeFromSupernode()
                strongSelf.highlightedContentNode = nil
            })
        }
    }
}
