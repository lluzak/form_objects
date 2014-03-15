# FormObjects

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

```
class AddressForm < FormObjects::Base
  attribute :street, String
  attribute :city, String
  
  validates :street, presence: true
end

class PersonalInfoForm < FormObjects::Base
  attribute :first_name, String
  attribute :last_name, String

  validates :first_name, presence: true
end

class UserForm < FormObjects::Base
  attribute :email, String

  attribute :addresses, Array[AddressForm]
  attribute :personal_info, PersonalInfoForm
  
  nested_forms :personal_info, :addresses
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
