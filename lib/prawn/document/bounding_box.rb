module Prawn 
  class Document       
    class BoundingBox

      def initialize(point,options={})
        @x,@y = point
        @width, @height = options[:width], options[:height]
      end

      def anchor
        [@x, @y - @height]
      end

      def left   
        0 
      end

      def right
        @width
      end

      def top
        @height
      end

      def bottom
        0
      end

      def absolute_left
        @x
      end

      def absolute_right
        @x + @width
      end

      def absolute_top
        @y
      end

      def absolute_bottom
        @y - @height
      end
    end
  end
end
