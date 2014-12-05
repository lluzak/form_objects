# FormObjects

[![Code Climate](https://codeclimate.com/github/lluzak/form_objects.png)](https://codeclimate.com/github/lluzak/form_objects)
[![Build Status](https://travis-ci.org/lluzak/form_objects.png?branch=master)](https://travis-ci.org/lluzak/form_objects)

FormObjects gives you a easy way of building complex and nested form objects.

## Installation

Add this line to your application's Gemfile:

    gem 'form_objects'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install form_objects

## Usage

In this micro-library you will not find any magic. Explicit is better than implicit. Simple is better than complex.

### Standard form

At the beginning of the life of your application most of the objects is exactly the same as the form. User include `first_name` and `last_name`.
Only `first_name` is required.

```ruby
class User
  validates :first_name, :presence => true
end
```

```ruby
# controller

def new
  @user = User.new
end
```

```erb
<%= form_for @user do |f| %>
  <%= f.label :first_name %>:
  <%= f.text_field :first_name %><br />

  <%= f.label :last_name %>:
  <%= f.text_field :last_name %><br />

  <%= f.submit %>
<% end %>
```

## Form with FormObjects

How the same can be achieved using `FormObjects`?

```ruby
class UserForm < FormObjects::Base
  field :first_name, String
  field :last_name, String

  validates :first_name, presence: true
end
```

Out new `UserForm` class does not know nothing about user. Because there is no connection to database.
That is why you need to explicitly defined each field. First argument is name of attribute and second argument is type
of this attribute. `#field` method is just alias for `attribute` method from [virtus](https://github.com/solnic/virtus#using-virtus-with-classes).

On `FormObjects` you can use the same validations like in `ActiveRecord::Base` object. So here there is no change.


```ruby
# controller

def new
  @user_form = UserForm.new
end
```

```erb
<%= form_for @user_form do |f| %>
  <%= f.label :first_name %>:
  <%= f.text_field :first_name %><br />

  <%= f.label :last_name %>:
  <%= f.text_field :last_name %><br />

  <%= f.submit %>
<% end %>
```

## How to save FormObject do database?

Ok, now we can just save user to our storage. Do you you think about `@user_form.save`?

![](http://dc472.4shared.com/img/G-w_8x6P/s3/13754405010/Nooo.gif)

Keep your objects simple. Form object is responsible for maintaining and validating data. Things like storing these data leave other objects. So what now?
You can create `UserCreator`.

```ruby
class UserCreator
  def initialize(attributes)
    @attributes = attributes
  end

  def create
    User.create(@attributes)
  end
end
```

## Namespace for attributes

Rails form generator will generate form with attributes scoped in `user_form`. So when you submit your form `params` will look like this:

```ruby
{
  :user_form => {
    :first_name => "First name",
    :last_name  => "Last name"
  }
}
```

You can change it by adding `FormObjects::Naming` to your form class definition.

```ruby
class UserForm < FormObjects::Base
  include FormObjects::Naming

  field :first_name, String
  field :last_name, String

  validates :first_name, presence: true
end
```

`FormObjects::Naming` will generate `.model_name` method. This method will return `ActiveModel::Name` object who will pretend that the model does not include `Form` in the name.
You can of course define your own `.model_name` method.

```ruby
class UserForm < FormObjects::Base
  field :first_name, String
  field :last_name, String

  validates :first_name, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "User")
  end
end
```

After this change params will look like this:

```ruby
{
  :user => {
    :first_name => "First name",
    :last_name  => "Last name"
  }
}
```

So we can implement `create` controller action.


```ruby
# controller

def create
  @user_form = UserForm.new(params[:user])

  if @user_form.valid?
    UserCreator.new(@user_form.serialized_attributes).create
  else
    render :new
  end
end
```

## Additional attribute

Let's do something standard. Add term and condition checkbox. In rails way you will add `term` attribute to your `User` model, didn't you?
Do not you think it's a little weird? I think so. Let's do this in `UserForm`.

```ruby
class UserForm < FormObjects::Base
  include FormObjects::Naming

  field :first_name, String
  field :last_name, String
  field :terms, Boolean

  validates :first_name, presence: true
  validates :terms, acceptance: true
end
```

But there is a problem with `terms` validation.

```ruby
UserForm.new(:terms => "1")
# => #<UserForm:0x00000004bbd2e0 @first_name=nil, @last_name=nil, @terms=true>
```

Virtus library will transform `terms` value into boolean. But by default `acceptance` will look for `"1"` value.

```ruby
form = UserForm.new(:terms => "1")
# => #<UserForm:0x00000004be2400 @first_name=nil, @last_name=nil, @terms=true>
form.valid?
# => false
form.errors.full_messages
# => ["First name can't be blank", "Terms must be accepted"]
```

Solution? You can change `terms` field into `String` type. But this is strange. I recommended clarify validation.

```ruby
class UserForm < FormObjects::Base
  include FormObjects::Naming

  field :first_name, String
  field :last_name, String
  field :terms, Boolean

  validates :first_name, presence: true
  validates :terms, acceptance: { accept: true }
end
```

Now everything should works just fine. No magic.

```ruby
form = UserForm.new(:terms => "1")
# => #<UserForm:0x00000004de7f20 @terms=true, @first_name=nil, @last_name=nil>
form.valid?
# => false
form.errors.full_messages
# => ["First name can't be blank"]
# No terms errors
```

## Form in form (nested_form)

Let add another form to our `UserForm`. User during registration should give the address. Lets create `LocationForm`.

```ruby
class LocationForm < FormObjects::Form
  field :address, String

  validates :address, presence: true
end
```

Instead of `field` method we need to use `nested_form`.

```ruby
class UserForm < FormObjects::Base
  include FormObjects::Naming

  field :first_name, String
  field :last_name, String
  field :terms, Boolean

  nested_form :address, LocationForm

  validates :first_name, presence: true
  validates :terms, acceptance: { accept: true }
end
```

I will switch now to `simple_form`. But you can use original `form_for` form rails.

```ruby
<%= simple_form_for @user_form, :url => homes_path do |f| %>
  <%= f.input :first_name %>
  <%= f.input :last_name %>
  <%= f.input :terms, :as => :boolean %>

  <%= f.simple_fields_for :address do |a| %>
    <%= a.input :address %>
  <% end %>

  <%= f.button :submit %>
<% end %>
```

You will notice one problem. That `address` field is not rendered. The reason is that `LocationForm` is not initialized.
You can use Virtus `default` attribute to accomplish this.

```ruby
class UserForm < FormObjects::Base
  include FormObjects::Naming

  field :first_name, String
  field :last_name, String
  field :terms, Boolean

  nested_form :address, LocationForm, default: proc { LocationForm.new }

  validates :first_name, presence: true
  validates :terms, acceptance: { accept: true }
end
```

After this change location form should be rendered. When you submit this form params will looks like:

```ruby
{
  :user => {
    :first_name => "FirstName",
    :last_name  => "LastName",
    :terms      => "1",
    :address_attributes => {
      :address => "Street"
    }
  }
}
```

When you pass these `params` to form object you can use `serialized_attriubtes` method. It will return developer-friendly hash with values.

```ruby
UserForm.new(params).serialized_attributes
# => {:first_name=>"FirstName", :last_name=>"LastName", :terms=>true, :address=>{:address=>"Street"}}
```

You can use this `Hash` inside your classes, services etc.

## Many forms in form

What we should do when we need more than 1 address? We can use `Array` from Virtus.

```ruby
class UserForm < FormObjects::Base
  include FormObjects::Naming

  field :first_name, String
  field :last_name, String
  field :terms, Boolean

  nested_form :addresses, Array[LocationForm]

  validates :first_name, presence: true
  validates :terms, acceptance: { accept: true }
end
```

I changed `address` to `addresses` and instead of simple `LocationForm` we will use `Array[LocationForm]`. But once again problem with default values.
You can use `default` attribute from Virtus.

```ruby
Array.new(2, LocationForm.new)
# => [#<LocationForm:0x00000004ffe0e8 @address=nil>, #<LocationForm:0x00000004ffe0e8 @address=nil>]
```

So we can apply this to our form.

```ruby
class UserForm < FormObjects::Base
  include FormObjects::Naming

  NUMBER_OF_LOCATION_FORMS = 2

  field :first_name, String
  field :last_name, String
  field :terms, Boolean

  nested_form :addresses, Array[LocationForm], default: proc { Array.new(NUMBER_OF_LOCATION_FORMS, LocationForm.new) }

  validates :first_name, presence: true
  validates :terms, acceptance: { accept: true }
end
```

After this your form will be renderer. But almost for sure you will get exception:

```
undefined method `0=' for #<LocationForm:0x007fdbc002bb80>
```

Now our params looks like this:

```ruby
{
  :user =>{
    :first_name => "FirstName",
    :last_name" => "LastName",
    :terms      => "1",
    :addresses_attributes => {
      "0" => {:address=>"Street1"},
      "1" => {"address=>"Street2"}
    }
  }
}
```

From now we need to use `FormObjects::ParamsConverter`. Because Virtus models will not accept rails magic.

```ruby
FormObjects::ParamsConverter.new(params).params

{
  :user => {
    :first_name => "FirstName",
    :last_name  => "LastName",
    :terms      => "1",
    :addresses_attributes=> [
      {:address => "Street1"},
      {:address => "Street2"}
    ]
  }
}
```

`FormObjects::ParamsConverter` convert `Hash` created by rails to friendly Array. You can use this Hash to initialize your form.

```ruby
UserForm.new(converted_params[:user])

private

def converted_params
  FormObjects::ParamsConverter.new(params).params
end
```

## Summary

* FormObjects use Virtus for Property API
* Nested forms objects are validate together with parent form, errors are being push to parent.
* ``` #serialized_attributes ``` method returns attributes hash

```ruby
class AddressForm < FormObjects::Base
  field :street, String
  field :city, String

  validates :street, presence: true
end

class PersonalInfoForm < FormObjects::Base
  field :first_name, String
  field :last_name, String

  validates :first_name, presence: true
end

class UserForm < FormObjects::Base
  field :email, String

  nested_form :addresses, Array[AddressForm]
  nested_form :personal_info, PersonalInfoForm
end

service = UserUpdater.new
form = UserForm.new

form.update({
  email: 'john.doe@example.com',
  personal_info_attributes: {first_name: 'John'},
  addresses_attributes: [{street: 'Golden Street'}]
})

if form.valid?
  service.update(form.serialized_attributes)
end
```

# Params conversion

## Array parameters

When you use HTTP there is no ensure that parameters that you receive will be ordered. That why rails wrap Arrays inside Hash.

```ruby
["one", "two", "three"] => {"0" => "one", "1" => "two", "2" => "three"}
```

But form object expects that nested params will be kind of Array

```ruby
class UserForm < FormObjects::Base
  nested_form :addresses, Array[AddressForm]
end

UserForm.new(:addresses_attributes => [{:name => "Name"}]) # good
# instead of
UserForm.new(:addresses_attributes => {"0" => {:name => "Name"}}) # bad
```

To avoid these problems you can use `FormObjects::ParamsConverter`.

```ruby
params = { "event_attributes" => {"0" => "one", "1" => "two", "2" => "three"} }
converter = FormObjects::ParamsConverter.new(params)
converter.params #=> { "event_attributes" => ["one", "two", "three"] }
```

## Date parameters

Multi-parameter dates can be easily converted to friendly form.

```ruby
  params = { "event" => { "date(1i)" => "2014", "date(2i)" => "12", "date(3i)" => "16", "date(4i)" => "12", "date(5i)" => "30", "date(6i)" => "45" } }
  converter = FormObjects::ParamsConverter.new(params)
  converter.params #=> { "event" => { "date" => "2014.12.16 12:30:45" } }
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
