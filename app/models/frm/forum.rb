require 'friendly_id'

module Frm
  class Forum < Frm::FrmTable
    include Frm::Concerns::Viewable

    extend FriendlyId
    friendly_id :name, :use => :slugged

    belongs_to :category

    belongs_to :group, class_name: '::Group', foreign_key: 'group_id'

    has_many :topics,     :dependent => :destroy
    has_many :posts,      :through => :topics, :dependent => :destroy
    has_many :moderators, :through => :moderator_groups, :source => :frm_group, class_name: 'Frm::Group'
    has_many :moderator_groups

    validates :category, :name, :description, :presence => true

    attr_accessible :category_id, :title, :name, :description, :moderator_ids

    alias_attribute :title, :name

    # Fix for #339
    default_scope order('name ASC')

    def last_post_for(forem_user)
      if forem_user && (forem_user.forem_admin? || moderator?(forem_user))
        posts.last
      else
        last_visible_post(forem_user)
      end
    end

    def last_visible_post(forem_user)
      posts.approved_or_pending_review_for(forem_user).last
    end

    def moderator?(user)
      user && (user.forem_group_ids & moderator_ids).any?
    end

    def to_s
      name
    end
  end
end