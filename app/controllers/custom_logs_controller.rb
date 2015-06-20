class CustomLogsController < ApplicationController

  def logs
    render text: (CustomLog.last.as_json)
  end

end
