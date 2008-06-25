$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
require "rubygems"
require "fastercsv"

headers, *body = FasterCSV.read("#{Prawn::BASEDIR}/examples/addressbook.csv")

Prawn::Document.generate("fancy_table.pdf", :page_layout => :landscape) do

  mask(:y) { table body, :headers => headers }

  table [["This is",   "A Test"    ],
         ["Of tables", "Drawn Side"],
         ["By side",   "and stuff" ]], 
    :position         => 550, 
    :headers          => ["Col A", "Col B"],
    :border           => 1,
    :vertical_padding => 2,
    :font_size        => 10,
    :row_colors       => ["ffffff","cccccc"],
    :widths => { 1 => 50 }

  move_down 200

  table [%w[1 2 3],%w[4 5 6],%w[7 8 9]], 
    :position => :center,
    :border_style => :grid,
    :font_size => 40

  cell [500,300],
    :text => "This free flowing textbox shows how you can use Prawn's "+
      "cells outside of a table with ease.  Think of a 'cell' as " +
      "simply a limited purpose bounding box that is meant for laying " +
      "out blocks of text and optionally placing a border around it",
    :width => 225, :padding => 10, :border => 2

  font_size! 24
  cell [50,75], 
    :text => "This document demonstrates a number of Prawn's table features",
    :border_style => :no_top, # :all, :no_bottom, :sides
    :horizontal_padding => 5

end
