$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

pdf = Prawn::Document.new

pdf.stroke_polygon [100, 250], [200, 300], [300, 250],
                   [300, 150], [200, 100], [100, 150]            

pdf.render_file "hexagon.pdf"
              

