class GroupUser < ActiveRecord::Base
  #sortable :user_id

  # Access Levels
  # Higher levels include all the levels below
  # So an owner is always a manager, etc
  OWNER = 200
  MANAGER = 150
  MEMBER = 50

  belongs_to :group, inverse_of: :group_users
  belongs_to :user, inverse_of: :group_users

  attr_accessible :access_level

  after_update :group_maintenance
  after_destroy :group_maintenance

  validates :user, :group, presence: true
  validates_uniqueness_of :user_id, scope: :group_id, if: :group_id

  scope :owners, lambda {where{access_level.gteq OWNER}}
  scope :managers, lambda {where{access_level.gteq MANAGER}}

  def is_owner?
    access_level >= OWNER
  end

  def is_manager?
    access_level >= MANAGER
  end

  protected

  def group_maintenance
    group.maintenance
  end
end
