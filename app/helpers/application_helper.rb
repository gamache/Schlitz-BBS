# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  ## returns stardate in string format
  def format_date(datetime)
    datetime ? datetime.strftime('%y%m%d %H%M') : ''
  end
end
