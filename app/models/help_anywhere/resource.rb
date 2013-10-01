class HelpAnywhere::Resource < ActiveRecord::Base
  attr_accessible :name
  has_many :pages, :class_name => HelpAnywhere::Page

  validates_presence_of :name
  validates_uniqueness_of :name

  before_destroy :destroy_pages

private
  def destroy_pages
    self.pages.each(&:destroy)
  end
end