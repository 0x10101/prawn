# encoding: utf-8
#
# stamp.rb : Implements a repeatable stamp
#
# Copyright October 2009, Daniel Nelson. All Rights Reserved.
#
# This is free software. Please see the LICENSE and COPYING files for details.
#

module Prawn
  module Stamp
    def stamp(user_defined_name)
      stamp_at(user_defined_name, [0, 0])
    end
    
    def stamp_at(user_defined_name, point)
      raise Prawn::Errors::InvalidName if user_defined_name.empty?
      unless stamp_dictionary_registry[user_defined_name]
        raise Prawn::Errors::UndefinedObjectName
      end
      
      add_content "q"
      x,y = point
      translate_position = "1 0 0 1 %.3f %.3f cm" % [x, y]
      add_content translate_position
      stamp_dictionary_name = stamp_dictionary_registry[user_defined_name][:stamp_dictionary_name]
      stamp_dictionary = stamp_dictionary_registry[user_defined_name][:stamp_dictionary]
      add_content "/#{stamp_dictionary_name} Do"
      add_content "Q"
      page_xobjects.merge!(stamp_dictionary_name => stamp_dictionary)
    end
    
    def create_stamp(user_defined_name="", &block)
      raise Prawn::Errors::InvalidName if user_defined_name.empty?
      if stamp_dictionary_registry[user_defined_name]
        raise Prawn::Errors::NameTaken
      end
      stamp_dictionary = ref!(:Type    => :XObject,
                              :Subtype => :Form,
                              :BBox => [0, 0, bounds.width, bounds.height])
      stamp_dictionary_name = "Stamp#{next_stamp_dictionary_id}"
      stamp_dictionary_registry[user_defined_name] = { :stamp_dictionary_name =>  stamp_dictionary_name, :stamp_dictionary => stamp_dictionary}

      
      @active_stamp_stream = ""
      @active_stamp_dictionary = stamp_dictionary
      yield if block_given?
      stamp_dictionary.data[:Length] = @active_stamp_stream.length + 1
      stamp_dictionary << @active_stamp_stream
      @active_stamp_stream = nil
      procs = @active_stamp_dictionary.data[:ProcSet]
      @active_stamp_dictionary.data.delete(:ProcSet)
      @active_stamp_dictionary = nil
      # The ProcSet needs to be assigned at the page level
      proc_set(procs) if procs
    end
    
    # Overriding page_content and current_page because while rendering
    # the block passed to create_stamp, any resources need to be added
    # to the stamp dictionary, not the page dictionary
    def page_content
      @active_stamp_stream || @store[@page_content]
    end

    # Overriding page_content and current_page because while rendering
    # the block passed to create_stamp, any resources need to be added
    # to the stamp dictionary, not the page dictionary
    def current_page
      @active_stamp_dictionary || @store[@current_page]
    end

    private

    def stamp_dictionary_registry
      @stamp_dictionary_registry ||= {}
    end

    def next_stamp_dictionary_id
      stamp_dictionary_registry.count + 1
    end
  end
end
