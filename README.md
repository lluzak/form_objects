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
)

if form.valid?
  service.update(form.serialized_attributes)
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
