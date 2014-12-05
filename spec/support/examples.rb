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
  attribute :author, String
end

class MessageForm < FormObjects::Base
  include FormObjects::Naming

  field :body, String
  field :author, String
end

class LocationForm < FormObjects::Base
  field :address, String

  validates :address, presence: true
end

class UserForm < FormObjects::Base
  include FormObjects::Naming

  field :first_name, String
  field :last_name, String
  field :terms, Boolean

  nested_form :addresses, Array[LocationForm], default: proc { Array.new(2, LocationForm.new) }

  validates :first_name, presence: true
  validates :terms, acceptance: { accept: true }
end
