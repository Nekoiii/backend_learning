module ApplicationHelper

  def full_title(page_title = '')
    base_title = APP_NAME
    [page_title, APP_NAME].compact.join(' | ')
  end


end
