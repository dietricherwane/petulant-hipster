class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Check if the parameter is not a number
  def not_a_number?(n)
  	n.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? true : false
  end

  # Overwriting the sign_out redirect path method
	def after_sign_out_path_for(resource_or_scope)
		new_user_session_path
	end

	def after_sign_in_path_for(resource_or_scope)
	  message_path #new_user_registration_path
	end
end
