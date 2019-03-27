class CustomerEmailTransactionsController < ApplicationController
  #prepend_before_filter :authenticate_user!

  layout "customer"

  def list
    @transactions_active = "active"
    @transaction_current_id = "current"
    @email_transaction_active_subclass = "this"
    @transactions = EmailTransaction.where("user_id = #{session[:customer].id}").order("created_at DESC")
    @transactions_count = @transactions.count
    @transactions = @transactions.page(params[:page])
  end
end
