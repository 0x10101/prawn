# encoding: utf-8
#
# Prawn::Table#initialize takes a <code>:before_rendering_page</code> argument,
# to adjust the way an entire page of table cells is styled. This allows you to
# do things like draw a border around the entire table as displayed on a page.
#
# The callback is passed a Cells object that is numbered based on the order of
# the cells on the page (e.g., the first row on the page is
# <code>cells.row(0)</code>).
#
require File.expand_path(File.join(File.dirname(__FILE__),
                                   %w[.. example_helper]))

filename = File.basename(__FILE__).gsub('.rb', '.pdf')
Prawn::Example.generate(filename) do
  table [["foo", "bar", "baz"]] * 40,
    :cell_style => { :border_width => 1 },
    :before_rendering_page => lambda { |page|
      page.row(0).border_top_width = 3
      page.row(-1).border_bottom_width = 3
      page.column(0).border_left_width = 3
      page.column(-1).border_right_width = 3
    }
end
