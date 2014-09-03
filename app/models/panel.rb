class Panel < ActiveRecord::Base
  extend FriendlyId

  validates :name, :presence => true
  validates :query, :presence => true

  friendly_id :slug_candidates, :use => [:slugged, :history]

  def slug_candidates
    [:name, [:name, :query], :query]
  end

  def should_generate_new_friendly_id?
    name_changed? || @name.blank? and query_changed? || super
  end
end
