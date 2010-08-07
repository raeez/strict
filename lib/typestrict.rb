module Strict
  VERSION = '0.0.5'
  
  class TypeError < Exception
    attr :errors
    def initialize(error_list)
      enforce!(:string_array, error_list, 'lib/typestrict')
      @errors = error_list
    end

    def inspect
      msg = "TypeError#{@errors.size > 1 ? "s" : ""} caught:\n"
      @errors.each do |e|
        msg += "#{e}\n"
      end
      return msg
    end
  end

  @@errors = []
  @@raise_exception = true
  @@dynamic_handlers = {}

  def setmode_raise!
    @@errors = []
    @@raise_exception = true
  end

  def setmode_catch!
    @@errors = []
    @@raise_exception = false
  end

  def catch_error error
    @@errors << error
    t = TypeError.new([error])
    raise(t, t.inspect, caller) if @@raise_exception
  end

  def raise_hell!
    t = TypeError.new(@@errors)
    raise(t, t.inspect, caller) if @@errors.size > 0
  end

  def register_supertype(supertype, handler)
    enforce_primitive!(Symbol, supertype)
    enforce_primitive!(Proc, handler)

    @@dynamic_handlers[supertype] = handler
    puts "registered a dynamic handler for supertype: #{supertype}"
  end

  def header(context, data)
    "#{context}; #{data.class.inspect}::#{data.inspect}"
  end

  def enforce_primitive!(type, data, context="Value")
    catch_error "#{header(context, data)} must be of type #{type}" unless (data.is_a? type and type.is_a? Class)
    return data
  end

  def enforce_strict_primitives!(types, data, context="Value")
    enforce_primitive!(Array, types, 'lib/typestrict')
    types.each {|type| enforce_primitive!(Object, type, 'lib/typestrict')}
    types.each do |type|
      enforce_primitive!(type, data, context)
    end
    return data
  end

  def enforce_weak_primitives!(types, data, context="Value")
    enforce_primitive!(Array, types, 'lib/typestrict')
    types.each {|type| enforce_primitive!(Object, type, 'lib/typestrict')}
    
    match_found = false
    types.each do |type|
      begin
        s = @@errors.size
        enforce_primitive!(type, data, context)
        match_found = true unless s != @@errors.size
      rescue
        next
      end
    end
    catch_error "#{header(context, data)} must be of one of the types of #{types.inspect}" unless match_found
    return data
  end

  def enforce_non_nil!(obj, context="Value")
    catch_error "#{context}: Object is nil!" if obj.nil?
    return obj
  end

  def enforce!(supertype, data, context="Value") #write a more generic handler, for new types?
    enforce_non_nil!(data, context)
    
    if supertype.is_a? Array #enumeration of values
      catch_error "#{header(context, data)} should take on a value within #{supertype.inspect}" unless supertype.include? data

    else if supertype.is_a? Symbol #distinct type
      case supertype
        when :string
          enforce_primitive!(String, data, context)
          catch_error "#{header(context, data)} can't be empty string" unless (data.size > 0)

        when :natural_number
          enforce_primitive!(Fixnum, data, context)
          catch_error "#{header(context, data)} must be > 0" unless (data > 0)

        when :integer
          enforce_primitive!(Fixnum, data, context)

        when :numeric
          enforce_primitive!(Numeric, data, context)

        when :boolean
          enforce_weak_primitives!([TrueClass, FalseClass], data, context)

        when :float
          enforce_primitive!(Float, data, context)

        when :character
          enforce!(:string, data, context)
          catch_error "#{header(context, data)} must be a single character!" unless data.size == 1

        when :procedure
          enforce_primitive!(Proc, data, context)

        when :string_array
          enforce_primitive!(Array, data, context)
          data.each {|item| enforce_primitive!(String, item, context)}

        when :numeric_array
          enforce_primitive!(Array, data, context)
          data.each {|item| enforce_primitive!(Numeric, item, context)}

        when :float_array
          enforce_primitive!(Array, data, context)
          data.each {|item| enforce_primitive!(Float, item, context)}

        when :integer_array
          enforce_primitive!(Array, data, context)
          data.each {|item| enforce_primitive!(Fixnum, item, context)}

        when :hex_color
          enforce!(:string, data, context)
          catch_error "#{header(context, data)} must be six characters long" unless (data.size == 6)
          data.upcase.each_byte {|c| catch_error "#{header(context, data)} must contain only hexadecimal characters" unless ((48 <= c  and c <= 57) or (65 <= c and c <= 70))}

        else
          if @@dynamic_handlers.has_key? supertype
            @@dynamic_handlers[supertype].call(data, context="Value")
          else
            catch_error "undefined symbol-supertype encountered: #{supertype.inspect}"
          end
        end
      end
    end
    return data
  end

  def enforce_map!(matrix, map)
    enforce_primitive!(Hash, matrix, "lib/typestrict")
    enforce_primitive!(Hash, map, "lib/typestrict")

    setmode_catch!

    matrix.each do |param, type|
      if map.has_key? param
        enforce!(type, map[param], "map[#{param.inspect}]")
      else
        catch_error "map: missing required param: #{param.inspect}"
      end
    end
    raise_hell!
    setmode_raise!
    return map
  end
end
