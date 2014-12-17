class Panel < ActiveRecord::Base
  extend FriendlyId

  validates :title, :presence => true
  validates :search_id, :presence => true

  friendly_id :slug_candidates, :use => [:slugged, :history]

  def slug_candidates
    [:title, :search_id]
  end

  def should_generate_new_friendly_id?
    title_changed? || @title.blank? and search_id_changed? || super
  end
end
