# encoding: utf-8

require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")           
require 'iconv'

describe "Font behavior" do  

  it "should default to Helvetica if no font is specified" do
    @pdf = Prawn::Document.new
    @pdf.font.name.should == "Helvetica"
  end

end    

describe "font style support" do
  before(:each) { create_pdf }
  
  it "should allow specifying font style by style name and font family" do    
    @pdf.font "Courier", :style => :bold
    @pdf.text "In Courier bold"    
    
    @pdf.font "Courier", :style => :bold_italic
    @pdf.text "In Courier bold-italic"   
     
    @pdf.font "Courier", :style => :italic
    @pdf.text "In Courier italic"    
    
    @pdf.font "Courier", :style => :normal
    @pdf.text "In Normal Courier"  
           
    @pdf.font "Helvetica"
    @pdf.text "In Normal Helvetica"     
    
    text = PDF::Inspector::Text.analyze(@pdf.render)
    text.font_settings.map { |e| e[:name] }.should == 
     [:"Courier-Bold", :"Courier-BoldOblique", :"Courier-Oblique", 
      :Courier, :Helvetica]
 end
      
end

describe "Transactional font handling" do
  before(:each) { create_pdf }
  
  it "should allow setting of size directly when font is created" do
    @pdf.font "Courier", :size => 16
    @pdf.font.size.should == 16 
  end
  
  it "should allow temporary setting of a new font using a transaction" do
    @pdf.font "Helvetica", :size => 12
    
    @pdf.font "Courier", :size => 16 do
      @pdf.font.name.should == "Courier"
      @pdf.font.size.should == 16
    end
    
    @pdf.font.name.should == "Helvetica"
    @pdf.font.size.should == 12
  end
  
end

describe "Document#page_fonts" do
  before(:each) { create_pdf } 
  
  it "should register fonts properly by page" do
    @pdf.font "Courier"; @pdf.text("hello")
    @pdf.font "Helvetica"; @pdf.text("hello")
    @pdf.font "Times-Roman"; @pdf.text("hello")
    ["Courier","Helvetica","Times-Roman"].each { |f|
      page_should_include_font(f)
    }                                        
    
    @pdf.start_new_page    
    @pdf.font "Helvetica"; @pdf.text("hello")
    page_should_include_font("Helvetica")
    page_should_not_include_font("Courier")
    page_should_not_include_font("Times-Roman")
  end    
  
  def page_includes_font?(font)
    @pdf.page_fonts.values.map { |e| e.data[:BaseFont] }.include?(font.to_sym)
  end                             
  
  def page_should_include_font(font)    
    assert_block("Expected page to include font: #{font}") do
      page_includes_font?(font)
    end
  end   
  
  def page_should_not_include_font(font)
    assert_block("Did not expect page to include font: #{font}") do
      not page_includes_font?(font) 
    end
  end
      
end
    
describe "AFM fonts" do
  
  setup do
    create_pdf
    @times = @pdf.find_font "Times-Roman"
    @iconv = ::Iconv.new('Windows-1252', 'utf-8')
  end
  
  it "should calculate string width taking into account accented characters" do
    @times.width_of(@iconv.iconv("é"), :size => 12).should == @times.width_of("e", :size => 12)
  end
  
  it "should calculate string width taking into account kerning pairs" do
    @times.width_of(@iconv.iconv("To"), :size => 12).should == 13.332
    @times.width_of(@iconv.iconv("To"), :size => 12, :kerning => true).should == 12.372
    @times.width_of(@iconv.iconv("Tö"), :size => 12, :kerning => true).should == 12.372
  end

  it "should encode text without kerning by default" do
    @times.encode_text(@iconv.iconv("To")).should == [[0, "To"]]
    @times.encode_text(@iconv.iconv("Télé")).should == [[0, @iconv.iconv("Télé")]]
    @times.encode_text(@iconv.iconv("Technology")).should == [[0, "Technology"]]
    @times.encode_text(@iconv.iconv("Technology...")).should == [[0, "Technology..."]]
  end

  it "should encode text with kerning if requested" do
    @times.encode_text(@iconv.iconv("To"), :kerning => true).should == [[0, ["T", 80, "o"]]]
    @times.encode_text(@iconv.iconv("Télé"), :kerning => true).should == [[0, ["T", 70, @iconv.iconv("élé")]]]
    @times.encode_text(@iconv.iconv("Technology"), :kerning => true).should == [[0, ["T", 70, "echnology"]]]
    @times.encode_text(@iconv.iconv("Technology..."), :kerning => true).should == [[0, ["T", 70, "echnology", 65, "..."]]]
  end
  
end

describe "TTF fonts" do
  
  setup do
    create_pdf
    @activa = @pdf.find_font "#{Prawn::BASEDIR}/data/fonts/Activa.ttf"
  end
  
  it "should calculate string width taking into account accented characters" do
    @activa.width_of("é", :size => 12).should == @activa.width_of("e", :size => 12)
  end
  
  it "should calculate string width taking into account kerning pairs" do
    @activa.width_of("To", :size => 12).should == 15.228
    @activa.width_of("To", :size => 12, :kerning => true).should == 12.996
  end
  
  it "should encode text without kerning by default" do
    @activa.encode_text("To").should == [[0, "To"]]
    @activa.encode_text("Télé").should == [[0, "T\216l\216"]]
    @activa.encode_text("Technology").should == [[0, "Technology"]]
    @activa.encode_text("Technology...").should == [[0, "Technology..."]]
    @activa.encode_text("Teχnology...").should == [[0, "Te"], [1, "!"], [0, "nology..."]]
  end

  it "should encode text with kerning if requested" do
    @activa.encode_text("To", :kerning => true).should == [[0, ["T", 186.0, "o"]]]
    @activa.encode_text("To", :kerning => true).should == [[0, ["T", 186.0, "o"]]]
    @activa.encode_text("Technology", :kerning => true).should == [[0, ["T", 186.0, "echnology"]]]
    @activa.encode_text("Technology...", :kerning => true).should == [[0, ["T", 186.0, "echnology", 88.0, "..."]]]
    @activa.encode_text("Teχnology...", :kerning => true).should == [[0, ["T", 186.0, "e"]], [1, "!"], [0, ["nology", 88.0, "..."]]]
  end
  
end
