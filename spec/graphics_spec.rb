require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")  

class LineDrawingObserver
  attr_accessor :points, :strokes

  def initialize
    @points = [] 
  end  

  def append_line(*params)
    @points << params
  end    
             
  def begin_new_subpath(*params)
    @points << params
  end
  
end                    
           
describe "When drawing a line" do
   
  before(:each) { create_pdf }
 
  it "should draw a line from (100,600) to (100,500)" do
    @pdf.line([100,600],[100,500])
    
    line_drawing = observer(LineDrawingObserver)
    
    line_drawing.points.should == [[100,600],[100,500]]       
  end  
  
  it "should draw two lines (100,600) to (100,500) and stroke each line" +
     "and (75,100) to (50,125)" do 
    @pdf.line(100,600,100,500) 
    @pdf.line(75,100,50,125)
    
    line_drawing = observer(LineDrawingObserver)
    
    line_drawing.points.should == 
      [[100.0, 600.0], [100.0, 500.0], [75.0, 100.0], [50.0, 125.0]]
  end
  
  class LineWidthReader 
    attr_accessor :width
    def set_line_width(params)
      @width = params
    end
  end
  
  it "should properly set line width" do
     create_pdf
     @pdf.line_width = 10
     line = observer(LineWidthReader)
     line.width.should == 10 
  end   
        
end                            

describe "When drawing a polygon" do

  before(:each) { create_pdf }

  it "should draw each line passed to polygon()" do
    @pdf.polygon([100,500],[100,400],[200,400])

    line_drawing = observer(LineDrawingObserver)
    line_drawing.points.should == [[100,500],[100,400],[200,400],[100,500]]
  end

end                                

class RectangleDrawingObserver
  
  attr_reader :point, :width, :height
  
  def append_rectangle(*params) 
    @point  = params[0..1]    
    @width  = params[2]
    @height = params[3]      
  end
end

describe "When drawing a rectangle" do

  before(:each) { create_pdf }

  it "should use a point, width, and height for coords" do
    @pdf.rectangle [200,200], 50, 100

    rectangle = observer(RectangleDrawingObserver)
    rectangle.point.should  == [200,200]
    rectangle.width.should  == 50
    rectangle.height.should == 100

  end

end

class CurveObserver
     
  attr_reader :coords
  
  def initialize
    @coords = []          
  end   
  
  def begin_new_subpath(*params)   
    @coords += params
  end
  
  def append_curved_segment(*params)
    @coords += params
  end           
  
end   

describe "When drawing a curve" do  
    
  before(:each) { create_pdf }
  
  it "should draw a bezier curve from 50,50 to 100,100" do
    @pdf.move_to  [50,50]
    @pdf.curve_to [100,100],:bounds => [[20,90], [90,70]]
    curve = observer(CurveObserver) 
    curve.coords.should == [50.0, 50.0, 20.0, 90.0, 90.0, 70.0, 100.0, 100.0] 
  end                             
  
  it "should draw a bezier curve from 100,100 to 50,50" do
    @pdf.curve [100,100], [50,50], :bounds => [[20,90], [90,75]] 
    curve = observer(CurveObserver)
    curve.coords.should == [100.0, 100.0, 20.0, 90.0, 90.0, 75.0, 50.0, 50.0] 
  end
  
end 

describe "When drawing an ellipse" do
  before(:each) do 
    create_pdf
    @pdf.ellipse_at [100,100], 25, 50
    @curve = observer(CurveObserver) 
  end       
  
  it "should move the pointer to the center of the ellipse after drawing" do
    @curve.coords[-2..-1].should == [100,100]
  end 
  
end  

describe "When drawing a circle" do
  before(:each) do 
    create_pdf
    @pdf.circle_at [100,100], :radius => 25 
    @pdf.ellipse_at [100,100], 25, 25
    @curve = observer(CurveObserver) 
  end       
  
  it "should stroke the same path as the equivalent ellipse" do 
    middle = @curve.coords.length / 2
    @curve.coords[0...middle].should == @curve.coords[middle..-1] 
  end
end    

describe "When using painting shortcuts" do
  before(:each) { create_pdf }
 
  it "should convert stroke_some_method(args) into some_method(args); stroke" do
    @pdf.should_receive(:line_to).with([100,100])
    @pdf.should_receive(:stroke)
    
    @pdf.stroke_line_to [100,100]
  end  
  
  it "should convert fill_some_method(args) into some_method(args); fill" do
    @pdf.should_receive(:line_to).with([100,100]) 
    @pdf.should_receive(:fill)
    
    @pdf.fill_line_to [100,100]
  end
  
  it "should not break method_missing" do
    lambda { @pdf.i_have_a_pretty_girlfriend_named_jia }.
      should raise_error(NoMethodError) 
  end
end