# document.rb : Implements PDF document generation for Prawn
#
# Copyright April 2008, Gregory Brown.  All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.

require "stringio"
require "prawn/document/page_geometry" 
require "prawn/document/bounding_box"
require "prawn/document/text"      

module Prawn
  class Document  
    
    include Prawn::Graphics    
    include Text                             
    include PageGeometry                             
    
    attr_accessor :page_size, :page_layout, :bounding_box    
             
    # Creates and renders a PDF document.  If a filename is given, the output
    # will be rendered to file, otherwise the result will be turned as a string.
    # The explicit receiver argument is necessary only when you need to make 
    # use of a closure.     
    #      
    #    # Using implicit block form and rendering to a file
    #    Prawn::Document.generate "foo.pdf" do
    #       font "Times-Roman"   
    #       text "Hello World", :at => [200,720], :size => 32       
    #    end
    #           
    #    # Using explicit block form and rendering to a file
    #    Prawn::Document.generate "foo.pdf" do |pdf|
    #       pdf.font "Times-Roman"
    #       pdf.text "Hello World", :at => [200,720], :size => 32
    #    end                                                
    #
    #    # Using implicit block form and rendering to string
    #    output = Prawn::Document.generate { stroke_line [100,100], [200,200] }    
    #    
    def self.generate(filename=nil,&block)
      pdf = Prawn::Document.new          
      block.arity < 1 ? pdf.instance_eval(&block) : yield(pdf)
      filename ? pdf.render_file(filename) : pdf.render
    end
          
    # Creates a new PDF Document.  The following options are available:
    #
    # <tt>:page_size</tt>:: One of the Document::PageGeometry::SIZES (default: LETTER)
    # <tt>:page_layout</tt>:: Either <tt>:portrait</tt> or <tt>:landscape</tt>
    # <tt>:on_page_start</tt>:: Optional proc run at each page start
    # <tt>:on_page_stop</tt>:: Optional proc  run at each page stop
    #                             
    #    # New document, US Letter paper, portrait orientation
    #    pdf = Prawn::Document.new                            
    #
    #    # New document, A4 paper, landscaped
    #    pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)    
    # 
    #    # New document, draws a line at the start of each new page
    #    pdf = Prawn::Document.new(:on_page_start => 
    #      lambda { |doc| doc.line [0,100], [300,100] } )
    #
    def initialize(options={})
       @objects = []
       @info    = ref(:Creator => "Prawn", :Producer => "Prawn")
       @pages   = ref(:Type => :Pages, :Count => 0, :Kids => [])  
       @root    = ref(:Type => :Catalog, :Pages => @pages)  
       @page_start_proc = options[:on_page_start]
       @page_stop_proc  = options[:on_page_end]              
       @page_size   = options[:page_size]   || "LETTER"    
       @page_layout = options[:page_layout] || :portrait
             
       ml = options[:left_margin]   || 36
       mr = options[:right_margin]  || 36  
       mt = options[:top_margin]    || 36
       mb = options[:bottom_margin] || 36
        
       @margin_box = BoundingBox.new( 
         [ ml, page_dimensions[-1] - mt ] , 
         :width => page_dimensions[-2] - (ml + mr), 
         :height => page_dimensions[-1] - (mt + mb)
       ) 
       
       @bounding_box = @margin_box
       
       start_new_page 
     end  
            
     # Creates and advances to a new page in the document.
     # Runs the <tt>:on_page_start</tt> lambda if one was provided at
     # document creation time (See Document.initialize).  
     #                                
     def start_new_page
       finish_page_content if @page_content
       @page_content = ref(:Length => 0)   
     
       @current_page = ref(:Type      => :Page, 
                           :Parent    => @pages, 
                           :MediaBox  => page_dimensions, 
                           :Contents  => @page_content,
                           :ProcSet   => font_proc,
                           :Resources => { :Font => {} } ) 
       set_current_font    
       update_colors
       @pages.data[:Kids] << @current_page
       @pages.data[:Count] += 1 
     
       add_content "q"   

       @page_start_proc[self] if @page_start_proc
    end             
      
    # Returns the number of pages in the document
    #  
    #    pdf = Prawn::Document.new
    #    pdf.page_count #=> 1
    #    3.times { pdf.start_new_page }
    #    pdf.page_count #=> 4
    def page_count
      @pages.data[:Count]
    end
       
    # Renders the PDF document, returning a string by default. 
    #
    def render
      output = StringIO.new       
      finish_page_content

      render_header(output)
      render_body(output)
      render_xref(output)
      render_trailer(output)
      output.string 
    end
     
    # Renders the PDF document to file.
    #
    #    pdf.render_file "foo.pdf"     
    #
    def render_file(filename)
      File.open(filename,"wb") { |f| f << render }
    end

    private
   
    def ref(data)
      @objects.push(Prawn::Reference.new(@objects.size + 1, data)).last
    end                                               
   
    def add_content(str)
     @page_content << str << "\n"
    end  
    
    def finish_page_content     
      @page_stop_proc[self] if @page_stop_proc
      add_content "Q"
      @page_content.data[:Length] = @page_content.stream.size
    end
    
    # Write out the PDF Header, as per spec 3.4.1
    def render_header(output)
      # pdf version
      output << "%PDF-1.1\n"

      # 4 binary chars, as recommended by the spec
      output << "\xFF\xFF\xFF\xFF\n"
    end

    # Write out the PDF Body, as per spec 3.4.2
    def render_body(output)
      @objects.each do |ref|
        ref.offset = output.size
        output << ref.object
      end
    end

    # Write out the PDF Cross Reference Table, as per spec 3.4.3
    def render_xref(output)
      @xref_offset = output.size
      output << "xref\n"
      output << "0 #{@objects.size + 1}\n"
      output << "0000000000 65535 f \n"
      @objects.each do |ref|
        output.printf("%010d", ref.offset)
        output << " 00000 n \n"
      end
    end

    # Write out the PDF Body, as per spec 3.4.4
    def render_trailer(output)
      trailer_hash = {:Size => @objects.size + 1, 
                      :Root => @root,
                      :Info => @info}

      output << "trailer\n"
      output << Prawn::PdfObject(trailer_hash) << "\n"
      output << "startxref\n" 
      output << @xref_offset << "\n"
      output << "%%EOF"
    end 
  end
end
