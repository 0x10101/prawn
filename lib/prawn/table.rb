# encoding: utf-8
#
# table.rb: Table drawing functionality.
#
# Copyright December 2009, Brad Ediger. All rights reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require 'prawn/table/accessors'
require 'prawn/table/cell'
require 'prawn/table/cell/in_table'
require 'prawn/table/cell/text'

module Prawn

  class Document
    
    # Set up and draw a table on this document. A block can be given, which will
    # be run prior to layout and drawing.
    #
    # See Prawn::Table#initialize for details on options.
    #
    def table(data, options={}, &block)
      t = Table.new(data, self, options, &block)
      t.draw
      t
    end

  end

  class Table  

    # Set up a table on the given document. Arguments:
    #
    # * data: A two-dimensional array of cell-like objects. See below for 
    # options for this argument.
    # * document: The Prawn::Document instance on which to draw the table.
    # * options: A hash of attributes and values for the table. 
    #
    # The data array can contain any combination of:
    #
    # * String: Produces a text cell.
    # TODO: more types
    #
    # Options can include:
    #
    # * cell_style: A hash of style options to style all cells. See the
    # documentation on Prawn::Table::Cell for all cell style options.
    #
    def initialize(data, document, options={}, &block)
      @pdf = document
      @cells = make_cells(data)
      options.each { |k, v| send("#{k}=", v) }

      # Evaluate the block before laying out the table, to support things like:
      #
      #   pdf.table(data) do |table|
      #     table.rows(1..3).width = 72
      #   end
      #
      if block
        block.arity < 1 ? instance_eval(&block) : block[self]
      end

      set_column_widths
      set_row_heights
      position_cells
    end                                        

    # Number of rows in the table.
    #
    attr_reader :row_length

    # Number of columns in the table.
    #
    attr_reader :column_length

    # Manually set the width of the table. This is the only way to get a table
    # wider than the document's bounds.
    #
    attr_writer :width
    
    # Returns the width of the table in PDF points.
    #
    def width
      @width ||= [natural_width, @pdf.bounds.width].min
    end

    # Returns the height of the table in PDF points.
    #
    def height
      cells.height
    end

    # Sets styles for all cells.
    #
    #   pdf.table(data, :cell_style => { :borders => [:left, :right] })
    #
    def cell_style=(style_hash)
      cells.style(style_hash)
    end

    # Allows generic stylable content.
    #
    #   pdf.table(data) do
    #     style(row(0), :background_color => 'ff00ff')
    #     style(column(0)) { |c| c.border_width += 1 }
    #   end
    #
    def style(stylable, style_hash={}, &block)
      stylable.style(style_hash, &block)
    end

    # Draws the table onto the document.
    #
    def draw
      top = @pdf.y
      @cells.each { |c| c.draw }
      @pdf.y = top - height
    end

    protected

    def make_cells(data)
      cells = []
      
      @row_length = data.length
      @column_length = data.map{ |r| r.length }.max

      data.each_with_index do |row_cells, row_number|
        row_cells.each_with_index do |cell_data, column_number|
          # TODO: differentiate based on content
          cell = Cell::Text.new(@pdf, [0, 0], :content => cell_data)
          cell.extend(Cell::InTable)
          cell.row = row_number
          cell.column = column_number
          cells << cell
        end
      end
      cells
    end

    def natural_column_widths
      @natural_column_widths ||= (0...column_length).map { |c| column(c).width }
    end

    def natural_width
      @natural_width ||= natural_column_widths.inject(0) { |sum, w| sum + w }
    end

    def column_widths
      @column_widths ||= begin
        widths = natural_column_widths

        overflow = (widths.inject { |sum, w| sum + w }) - width
        if overflow > 0
          # Expand table width to min width if needed.
          min_width = cells.min_width
          self.width = min_width if width < min_width

          # Shrink columns to bring natural width to width.
          widths.each_with_index do |col_width, i|
            # TODO: should we shrink large columns more than narrow ones?
            widths[i] = col_width * (width.to_f / natural_width)
          end
        elsif overflow < 0
          # Shrink table to max width if needed.
          max_width = cells.max_width
          self.width = max_width if width > max_width

          # Grow columns to bring natural width to width.
          widths.each_with_index do |col_width, i|
            # TODO: should we grow columns discriminately?
            widths[i] = col_width * (width.to_f / natural_width)
          end
        end

        widths
      end
    end

    def row_heights
      @natural_row_heights ||= (0...row_length).map{ |r| row(r).height }
    end

    def set_column_widths
      column_widths.each_with_index { |w, col_num| column(col_num).width = w }
    end

    def set_row_heights
      row_heights.each_with_index { |h, row_num| row(row_num).height = h }
    end

    # Set each cell's position based on the widths and heights of cells
    # preceding it.
    #
    def position_cells
      # Calculate x- and y-positions as running sums of widths / heights.
      x_positions = column_widths.inject([0]) { |ary, x| 
        ary << (ary.last + x); ary }[0..-2]
      x_positions.each_with_index { |x, i| column(i).x = x }

      y_positions = row_heights.inject([@pdf.cursor]) { |ary, y|
        ary << (ary.last - y); ary}[0..-2]
      y_positions.each_with_index { |y, i| row(i).y = y }
    end

  end


end
