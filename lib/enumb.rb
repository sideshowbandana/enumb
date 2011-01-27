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
    enum_columns[enum_column_name] = values
    
    attr_reader enum_column_name.to_sym unless instance_methods.include?(enum_column_name)
    attr_writer enum_column_name.to_sym unless instance_methods.include?("#{enum_column_name}=")
    
    define_class_method "decode_#{enum_column_name}" do |value|
      enum_columns[enum_column_name][value]
    end
    
    define_class_method "encode_#{enum_column_name}" do |value|
      enum_columns[enum_column_name].index(value)
    end

    define_method "#{enum_column_name}" do
      return decoded_value if decoded_value = instance_variable_get("@decoded_#{enum_column_name}")
      encoded_value = instance_variable_get("@#{enum_column_name}")
      unless encoded_value.nil?
        decoded_value = self.class.send("decode_#{attribute}".to_sym, encodeed_value)
        instance_variable_set("@decoded_#{enum_column_name}", decoded_value)
      end
      decoded_value
    end
    
    define_method "#{enum_column_name}=" do |value|
      unless value.nil?
        encoded_value = self.class.send("encode_#{attribute}".to_sym, value)
        instance_variable_set("@#{enum_column_name}", encoded)
      end
      value
    end
  end
end
