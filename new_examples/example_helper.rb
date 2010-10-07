# encoding: utf-8
#
# Helper for organizing examples
#

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'prawn'
require 'prawn/security'
require 'prawn/layout'


Prawn.debug = true

module Prawn
  
  class Example < Prawn::Document
  
    def self.generate_example_document(filename, examples)
      package = File.basename(filename).gsub('.rb', '.pdf')
      
      generate(package) do
        title = "#{package.gsub('.pdf', '').capitalize} Reference"
        text title, :size => 30
        
        package_page = page_number
        
        examples.each do |example|
          start_new_page
          
          text example, :size => 20
          move_down 10
          
          load_example(File.expand_path(File.join(
              File.dirname(filename), example)))
        end
        
        outline.define do 
          section title, :destination => package_page do
            examples.each_with_index do |example, index|
              page :destination => package_page + index + 1,
                   :title => example.gsub("_", " ").gsub(".rb", "").capitalize
            end
          end
        end
        
      end
    end
  
    def load_example(filename)
      data = File.read(filename)
      example_source = extract_source(data)
    
      text extract_introduction_text(data)
    
      bounding_box([bounds.left, cursor], :width => bounds.width) do
        font('Courier', :size => 11) do
          text example_source.gsub(' ', Prawn::Text::NBSP)
        end
        
        move_down 10
        dash(3)
        stroke_horizontal_line -36, bounds.width + 36
        undash
      end
      
      move_down 10
      eval example_source
    end
    
    def stroke_axis(options={})
      options = { :height => 350, :width => bounds.width.to_i }.merge(options)
      
      dash(1, :space => 4)
      stroke_horizontal_line -21, options[:width], :at => 0
      stroke_vertical_line -21, options[:height], :at => 0
      undash
      
      fill_circle_at [0, 0], :radius => 1
      (100..options[:width]).step(100).each do |point|
        fill_circle_at [point, 0], :radius => 1
        draw_text point, :at => [point-5, -10], :size => 7
      end

      (100..options[:height]).step(100).each do |point|
        fill_circle_at [0, point], :radius => 1
        draw_text point, :at => [-17, point-2], :size => 7
      end
    end
    
    def reset_drawing_settings
      self.line_width = 1
      self.cap_style  = :butt
      self.join_style = :miter
      undash
      fill_color "000000"
      stroke_color "000000"
    end

  private

    # Returns anything within the Example.generate block
    def extract_source(source)
      source.slice(/\w+\.generate.*? do(.*)end/m, 1) or source
    end
  
    # Returns the comments between the encoding declaration and the require
    def extract_introduction_text(source)
      intro = source.slice(/# encoding.*?\n(.*)require/m, 1)
      intro.gsub!(/\n# (?=\S)/m, ' ')
      intro.gsub!('#', '')
      intro.gsub!("\n", "\n\n")
      intro.rstrip!
      intro
    end
  end

end
