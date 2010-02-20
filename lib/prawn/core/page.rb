module Prawn
  module Core
    class Page
      def initialize(document, options={})
        @document = document
        @size     = options[:size]   ||  "LETTER" 

        @layout   = options[:layout] || :portrait 

        @margins  = options[:margins] || { :left    => 36,
                                           :right   => 36,
                                           :top     => 36,
                                           :bottom  => 36 }

        @content    = document.ref(:Length      => 0)
        @dictionary = document.ref(:Type        => :Page,
                                   :Parent      => document.state.store.pages,
                                   :MediaBox    => dimensions,
                                   :Contents    => content)

        resources[:ProcSet] = [:PDF, :Text, :ImageB, :ImageC, :ImageI]

        @stamp_stream      = nil
        @stamp_dictionary  = nil
      end

      attr_accessor :size, :layout, :margins, :document, :content, :dictionary

      def in_stamp_stream?
        !!@stamp_stream
      end

      def stamp_stream(dictionary)
        @stamp_stream     = ""
        @stamp_dictionary = dictionary

        document.send(:update_colors)
        yield if block_given?
        document.send(:update_colors)

        @stamp_dictionary.data[:Length] = @stamp_stream.length + 1
        @stamp_dictionary << @stamp_stream

        @stamp_stream      = nil
        @stamp_dictionary  = nil
      end

      def dimensions
        coords = Prawn::Document::PageGeometry::SIZES[size] || size
        [0,0] + case(layout)
        when :portrait
          coords
        when :landscape
          coords.reverse
        else
          raise Prawn::Errors::InvalidPageLayout,
            "Layout must be either :portrait or :landscape"
        end
      end

      def content
        @stamp_stream || document.state.store[@content]
      end

      def dictionary
        @stamp_dictionary || document.state.store[@dictionary]
      end

      def resources
        dictionary.data[:Resources] ||= {}
      end

      def fonts
        resources[:Font] ||= {}
      end

      def xobjects
        resources[:XObject] ||= {}
      end

      def ext_gstates
        resources[:ExtGState] ||= {}
      end

      def finalize
        content.compress_stream if document.compression_enabled?
        content.data[:Length] = content.stream.size
      end

    end
  end
end

