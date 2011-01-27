require 'eigenclass'

module Enumb
  def self.extended(base)
    base.instance_variable_set('@enum_columns', { })
  end
  
  # Contains a hash of enum columns and the values associated with each column
  # names as values
  #
  # Example
  #
  #   class User
  #     enum_column :foo, [:bar, :baz, :bat]
  #   end
  #
  #   User.enum_columns # { :foo => [:bar, :baz, :bat] }
  def enum_columns
    @enum_columns ||= superclass.enum_columns.nil? ? {} : superclass.enum_columns.dup
  end
  
  # Checks if an attribute has been configured to be encoded
  #
  # Example
  #
  #   class User
  #     attr_accessor :email
  #     enum_column :name
  #   end
  #
  #   User.enum_column?(:email) # false
  #   User.enum_column?(:name) # true
  def enum_column?(attribute)
    !enum_columns[attribute].nil?
  end
  
  protected
  
  # Generates attr_accessors that encode and decode enum values into integers transparently
  #
  # Example
  #
  #   class User < ActiveRecord::Base
  #     enum_column :platform, [:iphone, :windows_mobile, :android]
  #     enum_column :state, [:on, :off, :waiting]
  #   end
  #
  #   @user = User.new
  #   @user.platform = :iphone
  #   @user.platform
  # =>:iphone
  #   @user[:platform]
  # => 0 
  #   See README for more examples
  def enum_column(enum_column_name, values)
    values.map!(&:to_s)
    encode_hash = { }
    decode_hash = { }
    values.each_with_index do |v, idx|
      encode_hash[v] = idx
      decode_hash[idx] = v
    end
    enum_columns[enum_column_name] = values
    
    attr_reader enum_column_name.to_sym unless instance_methods.include?(enum_column_name)
    attr_writer enum_column_name.to_sym unless instance_methods.include?("#{enum_column_name}=")

    if should_use_named_scope?
      named_scope "with_#{enum_column_name}", lambda{ |value|
        {:conditions => { enum_column_name => send("encode_#{enum_column_name}", value)}}
      }
    else
      scope "with_#{enum_column_name}", lambda{ |value|
        {:conditions => { enum_column_name => send("encode_#{enum_column_name}", value)}}
      }
    end

    validates_inclusion_of enum_column_name, 
      :in => values, 
      :message => "%{value} is not included in the list #{values.inspect}",
      :unless => Proc.new{ |obj| obj.instance_variable_get("@decoded_#{enum_column_name}").blank? }
    
    define_class_method "decode_#{enum_column_name}" do |value|
      decode_hash[value]
    end
    
    define_class_method "encode_#{enum_column_name}" do |value|
      encode_hash[value.to_s]
    end

    define_method "#{enum_column_name}" do
      encoded_value = self[enum_column_name]
      decoded_value = self.class.send("decode_#{enum_column_name}".to_sym, encoded_value) || 
        instance_variable_get("@decoded_#{enum_column_name}")
      instance_variable_set("@decoded_#{enum_column_name}", decoded_value)
      decoded_value
    end
    
    define_method "#{enum_column_name}=" do |value|
      value = value.to_s unless value.nil?
      instance_variable_set("@decoded_#{enum_column_name}", value)
      encoded_value = self.class.send("encode_#{enum_column_name}".to_sym, value)
      self[enum_column_name] = encoded_value
    end
    
    define_method "encoded_#{enum_column_name}" do 
      self[enum_column_name]
    end
  end
end

##
# Backwards compatibility for rails 2
##
def should_use_named_scope?
  ActiveRecord::VERSION::MAJOR <= 2  
end

ActiveRecord::Base.extend(Enumb)
