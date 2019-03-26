class EmailTransactionsController < ApplicationController
  prepend_before_filter :authenticate_user!

  layout "administrator"

  def list
    @transactions_active = "active"
    @transaction_current_id = "current"
    @email_transaction_active_subclass = "this"
    @transactions = EmailTransaction.all.order("created_at DESC")
    @transactions_count = @transactions.count
    @transactions = @transactions.page(params[:page])
  end
end
