enumb
============

enumb is a library that will allow the use of enums in a database agnostic fashion. 

Download
--------

    gem install enumb

Defining Enum Columns
------------------

Each enum_column has a name and a set of attributes. The name is used to guess the class of the object by default, but it's possible to explicitly specify it:

      class User < ActiveRecord::Base
        enum_column :platform, [:iphone, :windows_mobile, :android]
        enum_column :state, [:on, :off, :waiting]
      end
    
Example

      @user = User.new
      @user.platform = :iphone
      @user.platform
    =>:iphone
      @user[:platform]
    => 0 
