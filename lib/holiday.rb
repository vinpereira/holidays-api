require 'mongoid'

# Models
class Holiday
  include Mongoid::Document

  field :name, type: String
  field :date, type: String
  field :city, type: String
  field :state, type: String
  field :federal, type: Boolean, default: false
  field :type, type: String

  validates :name, presence: true
  validates :date, presence: true
  validates :type, presence: true

  index({ name: 'text' })

  scope :date, -> (date) { where(date: date) }
  scope :month, -> (month) { where(date: /\/#{month}$/) }
  scope :city, -> (city) { where(city: /^#{city}/) }
  scope :state, -> (state) { where(state: /^#{state}/) }
  scope :federal, -> (federal) { where(federal: federal) }
  scope :type, -> (type) { where(type: type) }
end
