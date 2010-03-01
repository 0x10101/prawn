# -*- coding: utf-8 -*-
require File.join(File.expand_path(File.dirname(__FILE__)), "spec_helper")

describe "Text::Formatted::Parser#to_array" do
  it "should handle rgb" do
    string = "<color rgb='#ff0000'>red text</color>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[0].should == { :text => "red text",
                         :style => [],
                         :color => "ff0000",
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "# should be optional in rgb" do
    string = "<color rgb='ff0000'>red text</color>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[0].should == { :text => "red text",
                         :style => [],
                         :color => "ff0000",
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should handle cmyk" do
    string = "<color c='0' m='100' y='0' k='0'>magenta text</color>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[0].should == { :text => "magenta text",
                         :style => [],
                         :color => [0, 100, 0, 0],
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should handle fonts" do
    string = "<font name='Courier'>Courier text</font>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[0].should == { :text => "Courier text",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => "Courier",
                         :size => nil }
  end
  it "should handle size" do
    string = "<font size='14'>14 point text</font>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[0].should == { :text => "14 point text",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => 14 }
  end
  it "should handle links" do
    string = "<link href='http://example.com'>external link</link>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[0].should == { :text => "external link",
                         :style => [],
                         :color => nil,
                         :link => "http://example.com",
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should handle anchors" do
    string = "<link anchor='ToC'>internal link</link>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[0].should == { :text => "internal link",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => "ToC",
                         :font => nil,
                         :size => nil }
  end
  it "should handle higher order characters properly" do
    string = "<b>©\n©</b>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[0].should == { :text => "©",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[1].should == { :text => "\n",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[2].should == { :text => "©",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should convert &lt; &gt;, and &amp; to <, >, and &, respectively" do
    string = "hello <b>&lt;, &gt;, and &amp;</b>"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[1].should == { :text => "<, >, and &",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should handle double qoutes around tag attributes" do
    string = 'some <font size="14">sized</font> text'
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[1].should == { :text => "sized",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => 14 }
  end
  it "should handle single qoutes around tag attributes" do
    string = "some <font size='14'>sized</font> text"
    array = Prawn::Text::Formatted::Parser.to_array(string)
    array[1].should == { :text => "sized",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => 14 }
  end
  it "should construct a formatted text array from a string" do
    string = "hello <b>world\nhow <i>are</i></b> you?"
    array = Prawn::Text::Formatted::Parser.to_array(string)

    array[0].should == { :text => "hello ",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[1].should == { :text => "world",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[2].should == { :text => "\n",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[3].should == { :text => "how ",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[4].should == { :text => "are",
                         :style => [:bold, :italic],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[5].should == { :text => " you?",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should accept <strong> as an alternative to <b>" do
    string = "<strong>bold</strong> not bold"
    array = Prawn::Text::Formatted::Parser.to_array(string)

    array[0].should == { :text => "bold",
                         :style => [:bold],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[1].should == { :text => " not bold",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should accept <em> as an alternative to <i>" do
    string = "<em>italic</em> not italic"
    array = Prawn::Text::Formatted::Parser.to_array(string)

    array[0].should == { :text => "italic",
                         :style => [:italic],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[1].should == { :text => " not italic",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
  it "should accept <a> as an alternative to <link>" do
    string = "<a href='http://example.com'>link</a> not a link"
    array = Prawn::Text::Formatted::Parser.to_array(string)

    array[0].should == { :text => "link",
                         :style => [],
                         :color => nil,
                         :link => "http://example.com",
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
    array[1].should == { :text => " not a link",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }
  end
end


describe "Text::Formatted::Parser#to_string" do
  it "should handle rgb" do
    string = "<color rgb='ff0000'>red text</color>"
    array = [{ :text => "red text",
                         :style => [],
                         :color => "ff0000",
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }]
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
  it "should handle cmyk" do
    string = "<color c='0' m='100' y='0' k='0'>magenta text</color>"
    array = [{ :text => "magenta text",
                         :style => [],
                         :color => [0, 100, 0, 0],
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => nil }]
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
  it "should handle fonts" do
    string = "<font name='Courier'>Courier text</font>"
    array = [{ :text => "Courier text",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => "Courier",
                         :size => nil }]
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
  it "should handle size" do
    string = "<font size='14'>14 point text</font>"
    array = [{ :text => "14 point text",
                         :style => [],
                         :color => nil,
                         :link => nil,
                         :anchor => nil,
                         :font => nil,
                         :size => 14 }]
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
  it "should handle size" do
    array = [{ :text => "external link",
               :style => [],
               :color => nil,
               :link => "http://example.com",
               :anchor => nil,
               :font => nil,
               :size => nil }]
    string = "<link href='http://example.com'>external link</link>"
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
  it "should handle links" do
    array = [{ :text => "external link",
               :style => [],
               :color => nil,
               :link => "http://example.com",
               :anchor => nil,
               :font => nil,
               :size => nil }]
    string = "<link href='http://example.com'>external link</link>"
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
  it "should handle anchors" do
    array = [{ :text => "internal link",
               :style => [],
               :color => nil,
               :link => nil,
               :anchor => "ToC",
               :font => nil,
               :size => nil }]
    string = "<link anchor='ToC'>internal link</link>"
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
  it "should convert <, >, and & to &lt; &gt;, and &amp;, respectively" do
    array = [{ :text => "hello ",
               :style => [],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
            { :text => "<, >, and &",
               :style => [:bold],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil }]
    string = "hello <b>&lt;, &gt;, and &amp;</b>"
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
  it "should construct an HTML-esque string from a formatted" +
    " text array" do
    array = [
             { :text => "hello ",
               :style => [],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => 14 },
             { :text => "world",
               :style => [:bold],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
             { :text => "\n",
               :style => [:bold],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
             { :text => "how ",
               :style => [:bold],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
             { :text => "are",
               :style => [:bold, :italic],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil },
             { :text => " you?",
               :style => [],
               :color => nil,
               :link => nil,
               :font => nil,
               :size => nil }
             ]
    string = "<font size='14'>hello </font><b>world</b><b>\n</b><b>how </b><b><i>are</i></b> you?"
    Prawn::Text::Formatted::Parser.to_string(array).should == string
  end
end
