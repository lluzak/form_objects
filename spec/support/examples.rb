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
end
