# As of bbe1df6530455dff41768bcc329bdc7cfdfaded1 (and earlier),
# Prawn does not properly display cells with newlines in tables.
#
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "prawn"

Prawn::Document.generate("test.pdf") do
  table [["test\n\naaaa","test\n\nbbbb"],
        ["test\n\ncccc", "test\n\ndddd"]],  :border_style => :grid
    
  cell [100,100], :text => "test\n\naaaa"
end