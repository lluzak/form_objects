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

Summary:
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
