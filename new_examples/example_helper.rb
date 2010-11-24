# encoding: utf-8
#
# Helper for organizing examples
#

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'prawn'
require 'prawn/security'
require 'prawn/layout'

require 'enumerator'

Prawn.debug = true

module Prawn
  
  MANUAL_TITLE = "Prawn by Example"
  
  class Example < Prawn::Document
    
    def load_file(package, file)
      package_file = File.expand_path(File.join(
                          File.dirname(__FILE__), package, "#{file}.rb"))

      data = File.read(package_file)
      eval extract_generate_block(data)
    end

    def load_package(package)
      start_new_page
      load_file(package, package)
    end
    
    def load_page(page, page_name = nil)
      start_new_page
      load_file "manual", page

      outline.add_subsection_to Prawn::MANUAL_TITLE do
        outline.section page_name || page.capitalize,
                        :destination => page_number
      end
    end
    
    def build_package(package, examples_outline)
      title = package.gsub("_", " ").capitalize
      text title, :size => 30

      outline_package_root_section(title, page_number)
      
      build_package_examples(package, title, examples_outline)
    end

    def outline_package_root_section(title, page)
      if outline.items.include? Prawn::MANUAL_TITLE

        outline.add_subsection_to Prawn::MANUAL_TITLE do
          outline.section title, :destination => page
        end
      else
        outline.define do
          section title, :destination => page
        end
      end
    end
    
    def build_package_examples(package, title, examples_outline)
      examples_outline.each do |example_or_subsection|
        
        case example_or_subsection
        when Array
          
          outline.add_subsection_to title do 
            outline.section example_or_subsection.first,
                            :closed => true
          end
          
          build_package_examples package,
                                 example_or_subsection.first,
                                 example_or_subsection.last
          
        when Hash
          example = example_or_subsection.delete(:name)
          load_example(package, "#{example}.rb", example_or_subsection)
          
          outline.add_subsection_to title do 
            outline.page :destination => page_number,
                :title => example.gsub("_", " ").capitalize
          end
        
        else
          initial_page = page_number + 1
          load_example(package, "#{example_or_subsection}.rb")
          
          outline.add_subsection_to title do 
            outline.page :destination => initial_page,
                :title => example_or_subsection.gsub("_", " ").capitalize
          end
        end
      end
    end
  
    def load_example(package, example, options={})
      options = { :eval_source => true,
                  :full_source => false
                }.merge(options)
      
      example_file = File.expand_path(File.join(
                          File.dirname(__FILE__), package, example))
      
      data = File.read(example_file)
      
      if options[:full_source]
        example_source = extract_full_source(data)
      else  
        example_source = extract_generate_block(data)
      end
      
      start_new_page
      
      text "<color rgb='999999'>#{package}/</color>#{example}",
           :size => 20, :inline_format => true
      move_down 10
  
      text extract_introduction_text(data), :inline_format => true
  
      bounding_box([bounds.left, cursor], :width => bounds.width) do
        font('Courier', :size => 11) do
          text example_source.gsub(' ', Prawn::Text::NBSP)
        end
      end
      
      if options[:eval_source]
        move_down 10
        dash(3)
        stroke_horizontal_line -36, bounds.width + 36
        undash
      
        move_down 10
        eval example_source 
      end
    end
    
    def stroke_axis(options={})
      options = { :height => 350, :width => bounds.width.to_i }.merge(options)
      
      dash(1, :space => 4)
      stroke_horizontal_line -21, options[:width], :at => 0
      stroke_vertical_line -21, options[:height], :at => 0
      undash
      
      fill_circle_at [0, 0], :radius => 1
      (100..options[:width]).step(100) do |point|
        fill_circle_at [point, 0], :radius => 1
        draw_text point, :at => [point-5, -10], :size => 7
      end

      (100..options[:height]).step(100) do |point|
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

    # Returns everything except initial comments and require calls
    def extract_full_source(source)
      source.gsub(/# encoding.*?\n.*require.*?\n\n/m, "\n")
    end
    
    # Returns anything within the generate block
    def extract_generate_block(source)
      source.slice(/\w+\.generate.*? do(.*)end/m, 1) or source
    end
  
    # Returns the comments between the encoding declaration and the require
    def extract_introduction_text(source)
      intro = source.slice(/# encoding.*?\n(.*)require/m, 1)
      intro.gsub!(/\n# (?=\S)/m, ' ')
      intro.gsub!('#', '')
      intro.gsub!("\n", "\n\n")
      intro.rstrip!
      
      # Process the <code> tags
      intro.gsub!(/<code>([^<]+?)<\/code>/,
                  "<font name='Courier'>\\1<\/font>")
      
      intro
    end
  end

end
