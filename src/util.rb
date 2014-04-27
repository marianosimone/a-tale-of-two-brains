# Algunas clases utiles y monkey-patching de ruby

# Abro la clase Range, para agregarle un metodo "random"
class Range
  def random
    (first + rand(last-first)).floor
  end
end

# Abro la clase Array, para agregarle un metodo "random"
class Array
  def random
    index = (0..size).random
    self[index]
  end
end

# Ruby no tiene Enums... asi que se los agrego
class Enum
  def self.add_item(key,value)
    @hash ||= {}
    @hash[key] = value
  end

  def self.const_missing(key)
    value_for(key)
  end

  def self.each
    @hash.each {|key,value| yield(key,value)}
  end

  def self.name_for(value)
    @hash.each{|key, inner_value|
      return key if (inner_value == value)
    }
    raise "'#{self.name}' has no '#{value}' member"
  end

  def self.value_for(name)
    value = @hash[name.to_s] || @hash[name.to_sym]
    return value unless value.nil?
    raise "'#{self.name}' has no '#{name}' value defined"
  end
end

# Quiero una forma de darle nombres bonitos a las clases, asi que hago un modulo
module NicelyNamed
  def self.included(base)
    base.extend ClassMethods
  end

  # Este mapea nombres a clases
  def self.classes
    @@classes ||= {}
  end

  # Y este clases a nombres
  def self.names
    @@names ||= {}
  end

  def self.descriptions
    @@descriptions ||= {}
  end

  def self.get_class_from_name(name)
    # Primero, vemos si la clase esta en nuestro mapa... Si no, en todas las clases
    @@classes[name] || Kernel.const_get(name.gsub(" ",""))
    rescue NameError # pero puede que tampoco existiera...
      raise "There's no class named #{name.gsub(' ', '')}"
  end

  def nice_name
    self.class.nice_name
  end

  def class_description
    self.class.class_description
  end

  # Y estos son los metodos estatios que quiero agregar
  module ClassMethods
    def set_nice_name(name)
      NicelyNamed::names[self] = name
      NicelyNamed::classes[name] = self
    end

    def set_description(description)
      NicelyNamed::descriptions[self] = description
    end

    def nice_name
      NicelyNamed::names[self] ||= self.name.gsub(/([A-Z])/,' \1').strip!
    end

    def class_description
      NicelyNamed::descriptions[self] ||= self.nice_name
    end
  end  
end

def cartprod(*args)
  result = [[]]
  while [] != args
    t, result = result, []
    b, *args = args
    t.each do |a|
      b.each do |n|
        result << a + [n]
      end
    end
  end
  result
end
