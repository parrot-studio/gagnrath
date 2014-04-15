class Caller < ActiveRecord::Base
  include FortUtil

  belongs_to :situation

  validates :revision,
    presence: true,
    length: {maximum: 30}
  validates :gvdate,
    presence: true,
    length: {maximum: 10}
  validates :fort_group,
    presence: true,
    length: {maximum: 10}
  validates :fort_code,
    presence: true,
    length: {maximum: 10}
  validates :guild_name,
    presence: true,
    length: {maximum: 50}
  validates :reject_name,
    length:  {maximum: 50}

  scope :for_date,  lambda{|d| where(gvdate: d)}

end
