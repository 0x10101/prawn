# encoding: utf-8
#
# One important point when using Prawn is where the origin is placed on the
# page.
#
# Pdf documents have the origin [0,0] on the bottom left corner of the page.
#
# Bounding Boxes have the property of relocating the origin to its relative
# bottom left corner. The default margin for a document on Prawn is 0.5 inch.
# So the origin of the page on a default generated document isn't the absolute
# bottom left corner but the bottom left corner of the margin box.
#
# The following snippet strokes a circle on the margin box origin. Then strokes
# the boundaries of a bounding box and a circle on its origin
#
require File.expand_path(File.join(File.dirname(__FILE__),
    '..', 'example_helper.rb'))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  stroke_axis
  
  stroke_circle_at [0, 0], :radius => 10
  
  bounding_box [100, 300], :width => 300, :height => 200 do
    stroke_bounds
    stroke_circle_at [0, 0], :radius => 10
  end
end
