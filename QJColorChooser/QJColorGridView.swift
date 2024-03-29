//
//  ColorGridView.swift
//  QJColorChooser
//
//  Created by Joseph Essin on 4/15/16.
//  Updated for swift 5.1 and enhanced by Mike Manzo: '19
//

import Cocoa

/// A special view for rendering colors inside
/// a popover that belongs to JEColorButton.
/// This is where the magic happens.
class QJColorGridView: NSView {
  
  // MARK: Properties
  
  /// The parent button whose properties we implement
  fileprivate(set) var parent: QJColorChooser?
  
  /// Whether or not we can render menu items as selected.
  fileprivate(set) var canSelect: Bool = false
  
  /// This view uses flipped coordinates--top left is 0,0.
  override var isFlipped: Bool { get { return true } }
  
  /// Default menu rendering font.
    let menuFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
  
  /// The color that is currently active.
  fileprivate(set) var selectedColor: NSColor?
  
  /// Mouse coordinates relative to this view
  fileprivate(set) var mouse: NSPoint?
  
  /// The state of the menu's selection.
  fileprivate(set) var menuSelectionState: QJColorGridViewSelectionType = .colorGridSelection
  
  /// Mouse tracking tag
    var trackingTag: NSView.TrackingRectTag?
  
  /// X, Y, and Color of the selected color box.
  var selection: (CGFloat, CGFloat, NSColor)? = nil
  
  // MARK: Initializers
  
  /// Use this initializer inside of a JEColorButton to create a ColorGridView
  /// for the popover.
  /// - Parameter frame: The frame of the view (the entire popover)
  /// - Parameter belongsTo: The parent JEColorButton that owns the popover
  ///   that this view resides in.
  init(frame: NSRect, belongsTo: QJColorChooser) {
    // Initialize everything else:
    super.init(frame: frame)
    
    // We need a parent button to read its properties so our view
    // shows itself appropriately.
    parent = belongsTo
    // Track mouse movement inside our view.
    trackingTag = self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: false)
  }
  
  override func setFrameSize(_ newSize: NSSize) {
    super.setFrameSize(newSize)
    if let tag = trackingTag {
      self.removeTrackingRect(tag)
    }
    trackingTag = self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: false)
  }
  
  /// Don't use this initializer.
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  // MARK: Methods
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    //Draw a background color for the popover, if desired (but not recommended)
    if let backgroundColor = parent!.popoverBackgroundColor {
      backgroundColor.setFill()
      NSBezierPath.fill(CGRect(x: -100, y: -100, width: self.bounds.size.width + 100, height: self.bounds.size.height + 100))
    }
    
    //let context: NSGraphicsContext = NSGraphicsContext.currentContext()!
    
    if parent!.usesDefaultColor {
      // Render our default color menu item.
      // If it's selected, render it as selected, as well.
      let isSelected: Bool = (menuSelectionState == .defaultColorSelection) ? true : false
      if isSelected {
        // Render highlight
        let rect = CGRect(x: 0, y: 0, width: self.bounds.width, height: parent!.menuHeight)
        parent!.selectedMenuItemColor.setFill()
        NSBezierPath.fill(rect)
      }
      let title = parent!.defaultColorTitle
      let fontSize = menuTextSize(title)
      let y: CGFloat = (abs(parent!.menuHeight - fontSize.height) / 2.0)
      let boxY = (abs(parent!.menuHeight - parent!.boxHeight) / 2.0)
      
      drawMenuString(title, y: y, selected: isSelected)
      // Draw our box of color:
      drawColorBoxAt(CGPoint(x: parent!.horizontalMargin, y: boxY),
                     color: parent!.defaultColor, selected: isSelected)
    }
    
    // Render the grid of colors here.
    let menuHeight = parent!.menuHeight
    let xSpacing = parent!.horizontalBoxSpacing
    let ySpacing = parent!.verticalBoxSpacing
    let boxWidth = parent!.boxWidth
    let boxHeight = parent!.boxHeight
    let xMargin = parent!.horizontalMargin
    let yMargin = parent!.verticalMargin
    for row in 0..<parent!.rows {
      for column in 0..<parent!.columns {
        // Show each color
        let color = parent!.colors[row][column]
        let x = ((boxWidth + xSpacing) * CGFloat(column)) + xMargin
        let y = menuHeight + ((boxHeight + ySpacing) * CGFloat(row)) + yMargin

        drawColorBoxAt(CGPoint(x: x, y: y), color: color)
      }
    }
    
    // Draw the selection last so it's above everything else:
    if let (x, y, color) = selection {
      let rect = CGRect(x: x , y: y, width: parent!.boxWidth, height: parent!.boxHeight)
      let brightness = parent!.colorBrightness(color)
      if color.alphaComponent > 0.5 {
        if brightness < 0.5 { NSColor.white.setStroke() } else { NSColor.black.setStroke() }
      } else {
        NSColor.black.setStroke()
      }
//      NSBezierPath.setDefaultLineWidth(parent!.selectedBoxBorderWidth)
      NSBezierPath.defaultLineWidth = parent!.selectedBoxBorderWidth
      NSBezierPath.stroke(rect)
    }
    
    if parent!.usesCustomColor {
      // Render our custom color menu item.
      // If it's selected, render it as selected.
      let yStart: CGFloat = (self.bounds.height - parent!.menuHeight - ySpacing)
      var isSelected: Bool = (menuSelectionState == .customColorPanelDesired) ? true : false
      if isSelected {
        // Render highlight
        let rect = CGRect(x: 0, y: yStart, width: self.bounds.width, height: parent!.menuHeight + ySpacing)
        parent!.selectedMenuItemColor.setFill()
        NSBezierPath.fill(rect)
      }
      let title = parent!.customColorTitle
      let fontSize = menuTextSize(title)
      let y: CGFloat = yStart + (abs(self.bounds.height - yStart) - fontSize.height) / 2.0 - 1.0
      let boxY = yStart + (abs(self.bounds.height - yStart) - boxHeight) / 2.0
      drawMenuString(title, y: y, selected: isSelected)
      // Draw our box of color:
      if menuSelectionState == .customColorSelection { isSelected = true } else { isSelected = false }
      drawColorBoxAt(CGPoint(x: parent!.horizontalMargin, y: boxY),
                     color: parent!.customColor, selected: isSelected)
      
    }
  }
  
  // MARK: Mouse Events
  
  override func mouseEntered(with theEvent: NSEvent) {
    super.mouseEntered(with: theEvent)
    
    menuSelectionState = .colorGridSelection
    canSelect = true
    self.window!.acceptsMouseMovedEvents = true
    self.window!.makeFirstResponder(self) // Necessary
    selectedColor = nil
    self.setNeedsDisplay(self.bounds)
    self.displayIfNeeded()
  }
  
  override func mouseExited(with theEvent: NSEvent) {
    super.mouseExited(with: theEvent)
    
    canSelect = false
    super.mouseExited(with: theEvent)
    self.window!.acceptsMouseMovedEvents = false
    canSelect = false
    mouse = nil
    selectedColor = nil
    menuSelectionState = .colorGridSelection
    self.setNeedsDisplay(self.bounds)
    self.displayIfNeeded()
  }
  
  override func mouseDragged(with theEvent: NSEvent) {
    mouseMoved(with: theEvent)
  }
  
  override func mouseMoved(with theEvent: NSEvent) {
    super.mouseMoved(with: theEvent)
    
    var didSelect: Bool = false
    mouse = self.convert(theEvent.locationInWindow, from: nil)
    
    menuSelectionState = .colorGridSelection
    
    selectedColor = nil
    selection = nil
    
    if parent!.usesDefaultColor {
      // See if the default color menu item is selected:
      if mouse!.y >= 0 && mouse!.y <= parent!.menuHeight {
        menuSelectionState = .defaultColorSelection
        didSelect = true
      }
    }
    
    if parent!.usesCustomColor && !didSelect {
      // See if the custom color menu item is selected:
      
      let yStart: CGFloat = (self.bounds.height - parent!.menuHeight - parent!.verticalBoxSpacing)
      let boxX = parent!.horizontalMargin
      let boxY = yStart + (abs(self.bounds.height - yStart) - parent!.boxHeight) / 2.0
      let boxEndX = boxX + parent!.boxWidth
      let boxEndY = boxY + parent!.boxHeight
      
      if mouse!.y >= yStart && mouse!.y <= self.bounds.height {
        // We're in the menu area for the custom color selection. See if it's inside the custom
        // color rectangle, or just on the menu option and handle it appropriately
        if (mouse!.x >= boxX) && (mouse!.x <= boxEndX) &&
          (mouse!.y >= boxY) && (mouse!.y <= boxEndY) {
          // We're inside the custom color rectangle itself, so we want to pick the color, not open
          // the color panel
          menuSelectionState = .customColorSelection
          didSelect = true
        } else {
          // We want to open a the system color panel picker
          menuSelectionState = .customColorPanelDesired
          didSelect = true
        }
      }
    }
    
    // If we haven't selected anything already, look for a collision in the grid.
    if !didSelect {
      selectedColor = nil
      outerSearch: for row in 0..<parent!.rows {
        for column in 0..<parent!.columns {
          let color = parent!.colors[row][column]
          let halfBorder: CGFloat = parent!.boxBorderWidth / 2.0
          
          let x = ((parent!.boxWidth + parent!.horizontalBoxSpacing) * CGFloat(column)) + parent!.horizontalMargin
          let y = parent!.menuHeight + ((parent!.boxHeight + parent!.verticalBoxSpacing) * CGFloat(row)) + parent!.verticalMargin
          
          if mouse!.x >= x - halfBorder && mouse!.x <= x + parent!.boxWidth + halfBorder &&
            mouse!.y >= y - halfBorder && mouse!.y <= y + parent!.boxHeight + halfBorder {
            // We're hovering over a color in the grid
            selectedColor = color
            selection = (x, y, color)
            didSelect = true
            menuSelectionState = .colorGridSelection
            break outerSearch // Exit both for loops
          }
        }
      }
    }
    
    if didSelect {
      self.setNeedsDisplay(self.bounds)
      self.displayIfNeeded()
    } else {
      menuSelectionState = .noSelection
    }
  }
  
  override func mouseUp(with theEvent: NSEvent) {
    let delegate = parent! as QJColorGridViewDelegate
    if menuSelectionState == .colorGridSelection {
      delegate.colorWasSelected(self, color: selectedColor, selectionType: .colorGridSelection)
    } else if menuSelectionState == .customColorPanelDesired {
      delegate.colorWasSelected(self, color: parent!.customColor, selectionType: .customColorPanelDesired)
    } else if menuSelectionState == .defaultColorSelection {
      delegate.colorWasSelected(self, color: parent!.defaultColor, selectionType: .defaultColorSelection)
    } else if menuSelectionState == .customColorSelection {
      delegate.colorWasSelected(self, color: parent!.customColor, selectionType: .customColorSelection)
    }
  }
  
  // MARK: Private Methods
  
  /// Draws a color box at the specified point.
  /// - Parameter point: The upper-left corner of the box in view coordinates.
  /// - Parameter color: The color of the box to draw.
  fileprivate func drawColorBoxAt(_ point: CGPoint, color: NSColor, selected: Bool = false) {
    let rect = CGRect(x: point.x , y: point.y, width: parent!.boxWidth, height: parent!.boxHeight)
    if color.isEqualToColor(NSColor.clear) {
      // Clear color
      NSColor.white.setFill()
//      NSBezierPath.setDefaultLineWidth(2.0)
        NSBezierPath.defaultLineWidth = 2.0
      NSColor.red.setStroke()
      let line = NSBezierPath()
      line.move(to: NSMakePoint(point.x, point.y + parent!.boxHeight))
      line.line(to: NSMakePoint(point.x + parent!.boxWidth, point.y))
      line.stroke()
      NSBezierPath.fill(rect)
      line.stroke()
      adjustStrokeForSelection(selected)
      NSBezierPath.stroke(rect)
    } else {
      // Not clear color
      color.setFill()
      adjustStrokeForSelection(selected)
      NSBezierPath.fill(rect)
      NSBezierPath.stroke(rect)
    }
  }
  
  fileprivate func adjustStrokeForSelection(_ selected: Bool) {
    if selected {
      parent!.selectedBoxColor.setStroke()
//      NSBezierPath.setDefaultLineWidth(parent!.selectedBoxBorderWidth)
        NSBezierPath.defaultLineWidth = parent!.selectedBoxBorderWidth
    } else {
      parent!.boxBorderColor.setStroke()
//      NSBezierPath.setDefaultLineWidth(parent!.boxBorderWidth)
        NSBezierPath.defaultLineWidth = parent!.boxBorderWidth
    }
  }
  
  /// Draws a truncanted string as a menu label at the specified location.
  /// - Parameter string: The string to draw.
  /// - Parameter y: The vertical position to draw the string.
  /// - Parameter selected: True if the string is selected, false otherwise.
    fileprivate func drawMenuString(_ string: NSString, y: CGFloat, selected: Bool) {
        let str = UnwrappableString(string)
        let fontSize = menuTextSize(str)
        let x: CGFloat = (2.0 * parent!.horizontalBoxSpacing) + parent!.boxWidth + (parent!.horizontalMargin * 1.8)
        let width: CGFloat = self.bounds.width - x
        let height: CGFloat = min(parent!.menuHeight - y, fontSize.height)
        let rect: NSRect = NSRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width , height: height))
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        
        guard let textStyle = NSMutableParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle else {
            return
        }
        textStyle.alignment = .center
        var attributes = [NSAttributedString.Key.font: menuFont,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]

        if selected {
            attributes[NSAttributedString.Key.foregroundColor] = parent!.selectedMenuItemTextColor
        } else {
            attributes[NSAttributedString.Key.foregroundColor] = parent!.textColor
        }
        
        str.draw(with: rect,
                 options: [NSString.DrawingOptions.truncatesLastVisibleLine, NSString.DrawingOptions.usesLineFragmentOrigin],
                 attributes: attributes)
    }
/*  fileprivate func drawMenuString(_ string: NSString, y: CGFloat, selected: Bool) {
    let str = UnwrappableString(string)
    let fontSize = menuTextSize(str)
    let x: CGFloat = (2.0 * parent!.horizontalBoxSpacing) + parent!.boxWidth + (parent!.horizontalMargin * 1.8)
    let width: CGFloat = self.bounds.width - x
    let height: CGFloat = min(parent!.menuHeight - y, fontSize.height)
    let rect: NSRect = NSRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width , height: height))
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .byTruncatingTail
    var attributes: [String: AnyObject]? = [NSFontAttributeName.rawValue: menuFont, NSParagraphStyleAttributeName: style]
    if selected {
      attributes![NSForegroundColorAttributeName] = parent!.selectedMenuItemTextColor
    } else {
      attributes![NSForegroundColorAttributeName] = parent!.textColor
    }
    str.draw(with: rect,
             options: [NSString.DrawingOptions.truncatesLastVisibleLine, NSString.DrawingOptions.usesLineFragmentOrigin],
                     attributes: attributes)
  }
*/
  /// Calculates the size of given menu text given the width constraint of the popover.
  /// This is highly specific to the draw
  fileprivate func menuTextSize(_ string: NSString) -> CGSize {
    let str = UnwrappableString(string)
    let width: CGFloat = self.bounds.width - ((parent!.horizontalBoxSpacing * CGFloat(2.0)) + parent!.boxWidth)
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = .byTruncatingTail
    let attributes = [NSAttributedString.Key.font: menuFont, NSAttributedString.Key.paragraphStyle: style]
    let rect: NSRect = str.boundingRect(with: NSMakeSize(width, CGFloat.greatestFiniteMagnitude),
                                        options: [NSString.DrawingOptions.truncatesLastVisibleLine, NSString.DrawingOptions.usesLineFragmentOrigin],
                                                attributes: attributes, context: nil)
    return rect.size
  }
  
  /// Returns a string that is immune to line-wrapping.
  fileprivate func UnwrappableString(_ string: NSString) -> NSString {
    let str: String = string.replacingOccurrences(of: " ",
      with: "\u{a0}").replacingOccurrences(of: "-", with: "\u{2011}")
    return str as NSString
  }
}
