module Strict
  module SuperTypes

    @@handlers = {}
    @@called = false

    def registered?(supertype)
      enforce_primitive!(Symbol, supertype)
      Strict::Base.has_key? supertype
    end

    def register_default_supertypes! #must be called from an env including Base
      if @@called
        return
      else
        @@called = true
      end

      @@handlers[:string] = proc do |data, context|
        enforce_primitive!(String, data, context)
        catch_error "#{header(context, data)} can't be empty string" unless (data.size > 0)
      end

      @@handlers[:natural_number] = proc do |data, context|
        enforce_primitive!(Fixnum, data, context)
        catch_error "#{header(context, data)} must be > 0" unless (data > 0)
      end

      @@handlers[:integer] = proc do |data, context|
        enforce_primitive!(Fixnum, data, context)
      end

      @@handlers[:numeric] = proc do |data, context|
        enforce_primitive!(Numeric, data, context)
      end

      @@handlers[:boolean] = proc do |data, context|
        enforce_weak_primitives!([TrueClass, FalseClass], data, context)
      end

      @@handlers[:float] = proc do |data, context|
        enforce_primitive!(Float, data, context)
      end

      @@handlers[:character] = proc do |data, context|
        enforce!(:string, data, context)
        catch_error "#{header(context, data)} must be a single character!" unless data.size == 1
      end

      @@handlers[:procedure] = proc do |data, context|
        enforce_primitive!(Proc, data, context)
      end

      @@handlers[:hash_map] = proc do |data, context|
        enforce_primitive!(Hash, data, context)
      end

      @@handlers[:hex_color] = proc do |data, context|
        enforce!(:string, data, context)
        catch_error "#{header(context, data)} must be six characters long" unless (data.size == 6)
        data.upcase.each_byte {|c| catch_error "#{header(context, data)} must contain only hexadecimal characters" unless ((48 <= c  and c <= 57) or (65 <= c and c <= 70))}
      end

      @@handlers[:uri] = proc do |data, context|
        enforce!(:string, data, context)
      end


      @@handlers[:string_array] = proc do |data, context|
        enforce_primitive!(Array, data, context)
        data.each {|item| enforce_primitive!(String, item, context)}
      end

      @@handlers[:numeric_array] = proc do |data, context|
        enforce_primitive!(Array, data, context)
        data.each {|item| enforce_primitive!(Numeric, item, context)}
      end

      @@handlers[:float_array] = proc do |data, context|
        enforce_primitive!(Array, data, context)
        data.each {|item| enforce_primitive!(Float, item, context)}
      end

      @@handlers[:integer_array] = proc do |data, context|
        enforce_primitive!(Array, data, context)
        data.each {|item| enforce_primitive!(Fixnum, item, context)}
      end

      @@handlers[:hex_color_array] = proc do |data, context|
        enforce_primitive!(Array, data, context)
        data.each {|item| enforce!(:hex_color, item, context)}
      end

      @@handlers[:uri_array] = proc do |data, context|
        enforce_primitive!(Array, data, context)
        data.each {|item| enforce!(:uri, item, context)}
      end

      @@handlers.each do |supertype, handler|
        Base::register_supertype(supertype, handler, false) #verbose set to false
      end
    end
  end
end

# TODO implement uri correctly
# make catch_error collect in base.rb for supertypes
