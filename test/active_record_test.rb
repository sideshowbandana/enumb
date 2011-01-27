require File.dirname(__FILE__) + '/test_helper'

ActiveRecord::Base.establish_connection :adapter => 'sqlite3', :database => ':memory:'

def create_phones_table
  silence_stream(STDOUT) do
    ActiveRecord::Schema.define(:version => 1) do
      create_table :phones do |t|
        t.integer  :platform
        t.integer  :carrier
      end
    end
  end
end

# The table needs to exist before defining the class
create_phones_table

class Phone < ActiveRecord::Base
  enum_column :platform, [:iphone, :android, :windows_mobile, :symbian]
  enum_column :carrier, [:tmobile, :att, :verizon]
end

class PhoneWithValidation < Phone
  validates_presence_of :platform
end

class ActiveRecordTest < Test::Unit::TestCase
  
  def setup
    ActiveRecord::Base.connection.tables.each { |table| ActiveRecord::Base.connection.drop_table(table) }
    create_phones_table
  end
  
  def test_should_encode_platform
    @phone = Phone.new :platform => :iphone
    assert @phone.save, @phone.errors.inspect
    assert_not_nil @phone.encoded_platform
    assert_not_equal @phone.platform, @phone.encoded_platform
    phone = Phone.find(@phone.id)
    assert_equal @phone, phone
    assert_equal @phone.platform, phone.platform
  end
  

  def test_should_find_by_platform
    Phone.create!(:platform => :android)
    @phone = Phone.create!(:platform => :iphone)
    assert_equal @phone, Phone.with_platform(:iphone).first
  end
  
  def test_should_find_by_platform_and_carrier

    Phone.create!(:platform => :iphone, :carrier => :tmobile)
    @phone = Phone.create!(:platform => :iphone, :carrier => :verizon)
    assert_equal @phone, Phone.with_platform(:iphone).with_carrier(:verizon).first
  end
  
  def test_should_validate_presence_of_platform
    @phone = PhoneWithValidation.new
    assert !@phone.valid?
    assert @phone.errors[:platform]
  end
  
  def test_should_validate_inclusion_of_carrier
    @phone = PhoneWithValidation.new :platform => :iphone, :carrier => :foo
    assert !@phone.valid?
    assert @phone.errors[:carrier].first.include?("included"), @phone.errors.inspect
  end
  
  def test_setting_carrier_to_invalid
    @phone = PhoneWithValidation.new :platform => :iphone, :carrier => :att
    assert @phone.valid?
    @phone.carrier = :foo
    assert !@phone.valid?
  end
  
  def test_should_set_carrier_to_nil
    @phone = PhoneWithValidation.new :platform => :iphone, :carrier => :att
    assert @phone.valid?, @phone.errors.inspect
    @phone.carrier = nil
    assert @phone.save
    assert_nil @phone.carrier
    assert_nil Phone.find(@phone.id).carrier
  end
  
  def test_should_be_backwards_compatible
    Phone.class_eval do 
      attr_accessor :foo
    end
    Phone.stubs(:should_use_named_scope?).returns(true, false)
    Phone.expects(:named_scope).returns
    Phone.class_eval do 
      enum_column :foo, [:baz, :bat]
    end
    Phone.expects(:named_scope).never
    Phone.class_eval do 
      enum_column :foo, [:baz, :bat]
    end
  end
end
