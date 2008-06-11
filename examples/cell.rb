$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"
require "prawn/graphics/cell"

Prawn::Document.generate("cell.pdf", :left_margin=>0, :bottom_margin => 0) do 
  cell [100,500], :width => 100, :border => true, :padding => 5,
                  :text => "You know that kittens are made of mud!"
end
