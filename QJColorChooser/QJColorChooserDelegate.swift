//
//  JXColorButtonDelegate.swift
//  QJColorChooser Test
//
//  Created by Joseph Essin on 4/17/16.
//  Updated for swift 5.1 and enhanced by Mike Manzo: '19
//

import Cocoa

@objc public protocol QJColorButtonDelegate {
  func colorSelected(_ sender: QJColorChooser, color: NSColor)
}
