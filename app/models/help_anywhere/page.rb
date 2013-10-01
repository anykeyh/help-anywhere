class HelpAnywhere::Page < ActiveRecord::Base
  belongs_to      :resource, :class_name => HelpAnywhere::Resource
  has_many        :items, :class_name => HelpAnywhere::Item

  validates_presence_of :resource_id

  before_save :inc_page_number
  before_destroy :move_page_number
  before_destroy :destroy_items
private

  def inc_page_number
    if self.number.nil?
      if self.resource.pages.count > 0
        self.number = self.resource.pages.order('number ASC').select(:number).first.number + 1
      else
        self.number = 1
      end
    end
  end

  def move_page_number
    unless self.number.nil?
      self.resource.pages.where('number > ?', self.number).each do |page|
        page.number = page.number - 1
        page.save!
      end
    end
  end

  def destroy_items
    self.items.each(&:destroy)
  end
end
