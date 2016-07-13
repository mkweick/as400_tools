module ApplicationHelper
  
  def format_page_title
    @page_title.blank? ? 'AS400 Tools' : "#{@page_title} - AS400 Tools"
  end
end
