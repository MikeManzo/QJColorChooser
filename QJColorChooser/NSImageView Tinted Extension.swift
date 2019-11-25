//
//  NSImageView Tinted Extension.swift
//  QJColorChooser
//
//  Created by Joseph Essin on 4/16/16.
//  Updated for swift 5.1 and enhanced by Mike Manzo: '19
//

import AppKit
import Cocoa

extension NSImage {
  /**
   Returns a version of the image tinted to the specified color.
   Thanks, internet!
   https://lists.apple.com/archives/cocoa-dev/2009/Aug/msg01872.html
   - Parameter withColor: The color to tint the image.
   - Returns: The new, tinted image.
   */
  func tintedImage(_ withColor: NSColor) -> NSImage {
    let size = self.size
    let imageBounds = NSMakeRect(0, 0, size.width, size.height)
    let copiedImage = self.copy() as! NSImage
    copiedImage.lockFocus()
    withColor.set()
    NSBezierPath(rect: imageBounds).fill()
//    NSRectFillUsingOperation(imageBounds, NSCompositingOperation.sourceAtop)
    copiedImage.unlockFocus()
    return copiedImage
  }
}
