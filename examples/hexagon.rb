$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

pdf = Prawn::Document.new
                        
pdf.stroke_color "000000"            
pdf.fill_color "ff0000"
pdf.fill_polygon [100, 250], [200, 300], [300, 250],
                 [300, 150], [200, 100], [100, 150]            
                  
pdf.render_file "hexagon.pdf"
              

