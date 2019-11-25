//
//  JXColorGridViewDelegate.swift
//  QJColorChooser
//
//  Created by Joseph Essin on 4/16/16.
//  Updated for swift 5.1 and enhanced by Mike Manzo: '19
//

import Foundation
import Cocoa

/// What kind of color selection the user made inside the view.
@objc enum QJColorGridViewSelectionType: Int {
  /// A color was selected from the grid of colors
  case colorGridSelection
  /// A color was selected from the default color
  case defaultColorSelection
  /// A color was selected from the custom color menu option
  case customColorSelection
  /// A custom color selection is incoming, and the panel 12needs to be open
  case customColorPanelDesired
  /// Nothing was selected.
  case noSelection
}

/// Allows the JXColorGridView to communicate with its parent QJColorChooser.
@objc protocol QJColorGridViewDelegate {
  /// The user has chosen a color in the JXColorGridView and its ready to be dismissed.
  /// - Parameter sender: The JXColorGridView that the user chose a color from.
  /// - Parameter selectionType: What the context is of the color that was selected.
  @objc func colorWasSelected(_ sender: QJColorGridView, color: NSColor?, selectionType: QJColorGridViewSelectionType)
}
