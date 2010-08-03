module Strict
  VERSION = '0.0.1'

  def enforce_primitive!(type, data)
    raise "#{data} must be of type #{type}" unless (data.is_a? type and type.is_a? Class)
  end

  def enforce_strict_primitives!(types, data)
    enforce_primitive!(Array, types)
    types.each {|type| enforce_primitive!(Object, type)}
    types.each do |type|
      enforce_primitive!(type, data)
    end
  end

  def enforce_weak_primitives!(types, data)
    enforce_primitive!(Array, types)
    types.each {|type| enforce_primitive!(Object, type)}
    
    match_found = false
    types.each do |type|
      begin
        enforce_primitive!(type, data)
        match_found = true
      rescue
        next
      end
    end
    raise "#{data} must be of one of the types of #{types.inspect}" unless match_found
  end

  def enforce_non_nil!(obj)
    raise "Object is nil!" if obj.nil?
  end

  def enforce!(supertype, data) #write a more generic handler, for new types?
    enforce_non_nil!(data)
    
    if supertype.is_a? Array #enumeration of values
      raise "#{data} should take on a value within #{supertype.inspect}" unless supertype.include? data

    else if supertype.is_a? Symbol #distinct type
      case supertype
        when :string
          enforce_primitive!(String, data)
          raise "#{data} can't be empty string" unless (data.size > 0)

        when :hex_color
          enforce!(:string, data)
          raise "#{data} must be six characters long" unless (data.size == 6)
          data.upcase.each_byte {|c| raise "#{data} must contain only hexadecimal characters" unless ((48 <= c  and c <= 57) or (65 <= c and c <= 70))}

        when :natural_number
          enforce_primitive!(Fixnum, data)
          raise "#{data} must be > 0" unless (data > 0)

        when :integer
          enforce_primitive!(Fixnum, data)

        when :numeric
          enforce_primitive!(Numeric, data)

        when :boolean
          enforce_weak_primitives!([TrueClass, FalseClass], data)

        when :float
          enforce_primitive!(Float, data)

        when :string_array
          enforce_primitive!(Array, data)
          data.each {|item| enforce_primitive!(String, item)}

        when :numeric_array
          enforce_primitive!(Array, data)
          data.each {|item| enforce_primitive!(Numeric, item)}

        when :float_array
          enforce_primitive!(Array, data)
          data.each {|item| enforce_primitive!(Float, item)}

        when :integer_array
          enforce_primitive!(Array, data)
          data.each {|item| enforce_primitive!(Fixnum, item)}

        else
          raise "undefined symbol-supertype encountered: #{supertype.inspect}"
        end
      end
    end
  end

  def enforce_map!(requirements, args)
    enforce_primitive!(Hash, requirements)
    requirements.each do |param, type|
      if args.has_key? param
        enforce!(type, args[param])
      else
        raise "missing required param: #{param}"
      end
    end
  end
end
