class CustomersController < ApplicationController
  include MessagesHelper

  before_action :init_customer_view, only: [:new, :list]
  prepend_before_filter :authenticate_user!, only: [:new, :create]
  before_action :customer_authentication_filter

  layout "administrator"

  layout :select_layout

  def select_layout
    case session[:customer]
    when nil
        return "administrator"
      else
        return "customer"
    end
  end

  def new
    @customer = current_user.customers.new()
    @sms_providers = SmsProvider.all
    @customer_exists = (current_user.customers.count == 0 ? false : true)
  end

  def create
    init_customer_view
    @error_message = ""
    @success_message = ""
    #@customer_exists = (current_user.customers.count == 0 ? false : true)
    @existing_customer = current_user.customers.first rescue nil
    @sms_providers = SmsProvider.all

    #if @customer_exists#@existing_customer != blank?
      #params[:customer][:login] = @existing_customer.login #rescue nil
      #params[:customer][:password] = 'duke'
      #params[:password_confirmation] = 'duke'
    #end

    @customer = Customer.new(params[:customer].merge({user_id: params[:customer][:user_id], md5_password: Digest::MD5.hexdigest(params[:customer][:password]), clear_password: params[:customer][:password]}))

    if params[:customer][:password] =! params[:password_confirmation]
      @error_message = "Le mot de passe et sa confirmation doivent être identiques<br />"
      @error_message = messages!(@error_message + @customer.errors.full_messages.map { |msg| "#{msg}<br />" }.join, "error")
    else
      if @customer.save &&  @error_message.blank?
        #if @existing_customer.blank?
          ActiveRecord::Base.connection.execute("UPDATE customers SET password = '\' || pgp_sym_encrypt('#{Digest::MD5.hexdigest(@customer.password)}', 'Pilote2017@key#'), sms_allowed = #{true if @customer.bulk != 0}, email_allowed = #{true if @customer.bulk_email != 0} WHERE id = '#{@customer.id}'")# rescue nil
          CustomerMailer.welcome_email(@customer).deliver
          #ActiveRecord::Base.connection.execute("UPDATE customers SET password = pgp_sym_encrypt('#{Digest::MD5.hexdigest(@customer.password)}', 'Pilote2017@key#') WHERE id = '#{@customer.id}'")# rescue nil
        #else
          #ActiveRecord::Base.connection.execute("UPDATE customers SET password = '#{@existing_customer.password}', login = '#{@existing_customer.login}' WHERE user_id = #{current_user.id}")# rescue nil
        #end
        @success_message = messages!("Le client a été correctement créé", "success")
        @customer = current_user.customers.new()
      else
        @error_message = messages!(@error_message + @customer.errors.full_messages.map { |msg| "#{msg}<br />" }.join, "error")
      end
    end

    render :new
  end

  def edit
    @customer = current_user.customers.where("id = #{params[:customer_id]}").first rescue nil
    @sms_providers = SmsProvider.all

    if @customer.blank?
      @error_message = messages!("Le client n'a pas été trouvé", "error")
      render :list
    end
  end

  def update
    @error_message = ""
    @password = params[:customer][:password]
    @password_confirmation = params[:password_confirmation]
    @customer = current_user.customers.where("id = #{params[:customer][:id]}").first rescue nil
    @sms_providers = SmsProvider.all
    customer_params = params[:customer]
    if @customer.blank?
      @error_message = messages!("Le client n'a pas été trouvé", "error")
      render :list
    else
      if !@password.blank? || !@password_confirmation.blank?
        unless @password == @password_confirmation
          @error_message = messages!("Le mot de passe et sa confirmation doivent être identiques<br />", "error")
        end
      else
        customer_params.except!(:password, :id)
      end

      if @error_message.blank?
        if @customer.update_attributes(customer_params)
          ActiveRecord::Base.connection.execute("UPDATE customers SET password = pgp_sym_encrypt('#{Digest::MD5.hexdigest(@customer.password)}', 'Pilote2017@key#'), md5_password = '#{Digest::MD5.hexdigest(@customer.password)}' WHERE id = '#{@customer.id}'") rescue nil
          @success_message = messages!("Le profil du client: #{@customer.label} a été mis à jour", "success")
        else
          @error_message = messages!(@error_message + @customer.errors.full_messages.map { |msg| "#{msg}<br />" }.join, "error")
        end
      end
    end

    render :edit
  end

  def disable
    disble_enable(params[:customer_id], false, "désactivé")
  end

  def enable
    disble_enable(params[:customer_id], true, "activé")
  end

  def disble_enable(customer_id, status, status_text)
    @customers = current_user.customers.order("id DESC").page(params[:page])
    @customer = current_user.customers.where("id = #{customer_id}").first rescue nil

    if @customer.blank?
      @error_message = messages!("Le client n'a pas été trouvé", "error")
    else
      @customer.update_attributes(status: status)
      @success_message = messages!("Le client a été correctement #{status_text}", "success")
    end

    render :list
  end

  def list
    init_customer_view
    @customers = current_user.customers.order("id DESC").page(params[:page])
    @customers_count = @customers.count
  end

  def init_customer_view
    @customer_active = "active exp"
    @customer_current_id = "current"
    @new_customer_active_subclass = "this"
  end

  # Interface de connexion utilisateur
  def new_session

    render layout: false
  end

  #Vérification des informations de connexion utilisateur
  def create_session
    @email = params[:email]
    @password = params[:password]

    @customer = Customer.where("email = ?", @email)
    @error_message = messages!("Veuillez vérifier votre login", "error") if @customer.blank?
    if @error_message.blank?
      @error_message = messages!("Veuillez vérifier votre mot de passe", "error") if @customer.first.clear_password != @password
      if @error_message.blank?
        session[:customer] = @customer.first
      end
    end

    if @error_message.blank?
      redirect_to customer_message_path
    else
      render :new_session, layout: false
    end
  end

  def delete_session
    session.delete(:customer)
    @success_message = messages!("Vous êtes à présent déconnecté", "success")

    redirect_to customer_login_path
  end

  # Interface d'envoi de messages utilisateur
  def new_message
    init_message_view
  end

  def customer_edit

  end

  def customer_update
    @error_message = ""
    @password = params[:customer][:clear_password]
    @password_confirmation = params[:clear_password_confirmation]
    customer_params = params[:customer]
    if !@password.blank? || !@password_confirmation.blank?
      unless @password == @password_confirmation
        @error_message = messages!("Le mot de passe et sa confirmation doivent être identiques<br />", "error")
      end
    else
      customer_params.except!(:clear_password, :id)
    end

    if @error_message.blank?
      if session[:customer].update_attributes(customer_params.merge(:password => Customer.find_by_id(session[:customer].id).password))
        @success_message = messages!("Votre profil a été mis à jour", "success")
      else
        @error_message = messages!(@error_message + session[:customer].errors.full_messages.map { |msg| "#{msg}<br />" }.join, "error")
      end
    end

    render :customer_edit
  end

  def init_message_view
    @message_active = "active exp"
    @message_current_id = "current"
    @new_message_active_subclass = "this"

    @profiles = Profile.where("published IS NOT FALSE")
  end

end
