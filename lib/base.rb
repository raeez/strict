module Strict
  module Base
    
    class StrictTypeError < Exception
      attr :errors
      def initialize(error_list)
        enforce_primitive!(Array, error_list, "lib/typestrict")
        error_list.each {|item| enforce_primitive!(String, item, "lib/typestrict")}
        @errors = error_list
      end

      def inspect
        msg = "StrictTypeError#{@errors.size > 1 ? "s" : ""} caught:\n"
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
      if @@raise_exception
        t = StrictTypeError.new([error])
        raise(t, t.inspect, caller)
      else
        @@errors << error
      end
    end

    def raise_hell!
      if @@errors.size > 0
        t = StrictTypeError.new(@@errors)
        setmode_raise!
        raise(t, t.inspect, caller)
      end
    end

    def register_supertype(supertype, handler, verbose=true)
      enforce_primitive!(Symbol, supertype, "typestrict/register_supertype")
      enforce_primitive!(Proc, handler, "typestrict/register_supertype")

      @@dynamic_handlers[supertype] = handler
      puts "registered a handler for supertype: #{supertype}" if verbose
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

      raise_set_before = @@raise_exception
      previous_errors = @@errors
      setmode_catch!

      match_found = false
      types.each do |type|
        begin
          s = @@errors.size
          enforce_primitive!(type, data, context)
          match_found = true unless @@errors.size > s
        rescue
          next
        end
      end

      @@errors = previous_errors

      catch_error "#{header(context, data)} must be of one of the types of #{types.inspect}" unless match_found

      if raise_set_before
        raise_hell! unless match_found
        setmode_raise!
      end

      return data
    end

    def enforce_non_nil!(obj, context="Value")
      catch_error "#{context}: Object is nil!" if obj.nil?
      return obj
    end

    def enforce!(supertype, data, context="Value")
      enforce_non_nil!(data, context)
      
      if supertype.is_a? Array #enumeration of values
        catch_error "#{header(context, data)} should take on a value within #{supertype.inspect}" unless supertype.include? data

      else
        if supertype.is_a? Symbol #distinct supertype
          if @@dynamic_handlers.has_key? supertype
            @@dynamic_handlers[supertype].call(data, context)
          else
            catch_error "undefined symbol-supertype encountered: #{supertype.inspect}"
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
end
