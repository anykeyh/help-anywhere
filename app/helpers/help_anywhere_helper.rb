module HelpAnywhereHelper
  def can_edit_help?
    HelpAnywhere.config.has_edition_role? self
  end
end