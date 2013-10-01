class HelpAnywhere::Item < ActiveRecord::Base
  belongs_to :page, :class_name => HelpAnywhere::Page
  attr_accessible :class_id, :content, :height, :target, :width, :x, :y

  validates_presence_of :page_id, :class_id
end
