# text.rb : Implements PDF text primitives
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

module Prawn
  class Document
    module Text
      
      BUILT_INS = %w[ Courier Courier-Bold Courier-Oblique Courier-BoldOblique
          Helvetica Helvetica-Bold Helvetica-Oblique Helvetica-BoldOblique
          Times-Roman Times-Bold Times-Italic Times-BoldItalic
          Symbol ZapfDingbats ]                      
              
      def text(text,options)        
        x,y = options[:at]
        add_content %Q{
        BT
        /#{font_registry[fonts[@font]]} #{options[:size] || 12} Tf 
        #{x} #{y} Td 
        #{Prawn::PdfObject(text)} Tj 
        ET           
        }
      end 
      
      def register_font(name)   
        raise unless BUILT_INS.include?(name)    
        fonts[name] ||= ref(:Type     => :Font, 
                         :Subtype  => :Type1, 
                         :BaseFont => name.to_sym,
                         :Encoding => :MacRomanEncoding)           
      end   
      
      def font(name)
        @font = name              
        register_font(name)
        set_current_font
      end   
                   
      def set_current_font #:nodoc:                     
        font "Helvetica" unless fonts[@font]
        font_registry[fonts[@font]] ||= :"F#{font_registry.size + 1}"                                                                 
          
        @current_page.data[:Resources][:Font].merge!(
          font_registry[fonts[@font]] => fonts[@font] 
        )      
      end     
      
      def font_registry #:nodoc:
        @font_registry ||= {}
      end     
      
      def font_proc #:nodoc:
        @font_proc ||= ref [:PDF, :Text] 
      end                    
      
      def fonts #:nodoc:
        @fonts ||= {}
      end
      
      private :set_current_font, :font_registry, :font_proc, :fonts
        
    end
    
  end
end