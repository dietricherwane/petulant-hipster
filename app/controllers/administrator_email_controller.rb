class AdministratorEmailController < ApplicationController
  require "base64"
  include MessagesHelper

  #before_action :init_messages, only: [:send_message, :api_send_message, :filter_api_send_message]
  prepend_before_filter :authenticate_user!#, except: [:api_send_message, :filter_api_send_message, :api_bulk, :api_md5_encrypt]

  layout "administrator"

  def new
    init_view
  end

  def send_message
=begin
    CustomerMailer.send_email(params[:post][:email], params[:post][:object], params[:post][:message]).deliver

    @message_active = "active exp"
    @message_current_id = "current"
    @new_email_active_subclass = "this"

    @profiles = Profile.where("published IS NOT FALSE AND (customer_id IS NULL OR customer_id = #{session[:customer].id}) AND email IS TRUE")

    render :new
=end
    @profile_id = params[:post][:profile_id]
    @message = params[:post][:message]
    @email = params[:post][:email]
    @object = params[:post][:object]
    @sender = params[:post][:sender]
    @subscribers_file = params[:post][:subscribers_file]
    @error = false
    @error_status = 0

    validate_profile_id
    validate_message

    unless @error
      @profile = Profile.find_by_id(@profile_id)
      @service = "Administrator"
      if @profile
        if @profile.name == "Email unique"
          validate_email
        end
        if @profile.name == "Liste d'emails"
          validate_subscribers_email_file
        end
      end
    end

    unless @error
      @sent_messages = 0
      @failed_messages = 0
      deliver_messages
    end

    init_view

    @error_message = messages!(@error_message, "error")

    if @error_status == 0
      render :new
    else
      redirect_to administrator_finalize_email_profile_path(profile_id: @profile.id)
    end
  end

  def deliver_messages
    if @profile.name == "Email unique"
      set_transaction("Envoi de message à un email.", 1)
      send_message_request(@email, @object, @sender, @message)
      @transaction.update_attributes(ended_at: DateTime.now, send_messages: @sent_messages, failed_messages: @failed_messages, user_id: (current_user.id))
      @success_message = messages!("Le message a été envoyé. Veuillez consulter l'état de l'envoi dans la liste des tansactions.", "success")
    else
      if @profile.name == "Liste d'emails"
        set_transaction("Envoi de message à une liste d'emails.", 0)
        deliver_message_to_excel_list
      else
        if @profile.email_column.blank?
          @error_message = messages!("Veuillez définir la colonne contenant l'email", "error")
          @error_status = 1
        else
          @parameter = Parameter.first
          @message_backup = @message
          set_transaction("Envoi de message au pofil: #{@profile.name}.", 0)
          profile_data = ProfileData.where("profile_id = #{@profile.id}")
          #Thread.new do
            sent_messages = 0
            profile_data.each do |pd|
              email = pd.row_content.split(@parameter.profile_separator)[@profile.email_column]
              if not_an_email?(email)
              else
                @message = format_message(pd, @message)
                send_message_request(email, @object, @sender, @message)
                @message = @message_backup
                sent_messages += 1
              end
            end
            @transaction.update_attributes(ended_at: DateTime.now, send_messages: sent_messages, user_id: current_user.id)
          #end
          @success_message = messages!("Les messages ont été envoyés. Veuillez consulter l'état de l'envoi dans la liste des tansactions.", "success")
        end
      end
    end
  end

  def format_message(pd, message)
    unless @profile.aliases.blank?
      while !message.match(/\{.*?\}/).blank?
        ccolumn = message.match(/\{.*?\}/).to_s
        data_index = @profile.aliases.split(@parameter.profile_separator).index(ccolumn.gsub("{", "").gsub("}", ""))
        message = message.gsub(ccolumn.to_s, pd.row_content.split(@parameter.profile_separator)[data_index].to_s)
      end
    end

    return message
  end

  def deliver_message_to_excel_list
    Thread.new do
      @spreadsheet = Spreadsheet.open(@subscribers_file.path).worksheet(0)
      @spreadsheet.each do |row|
        email = row[0].to_s
        unless not_an_email?(email)
          send_message_request(email, @object, @sender, @message)
        end
      end
      @transaction.update_attributes(ended_at: DateTime.now, send_messages: @sent_messages, failed_messages: @failed_messages, number_of_messages: (@sent_messages + @failed_messages))
      if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
        ActiveRecord::Base.connection.close
      end
    end
    @success_message = messages!("Veuillez consulter l'état de l'envoi dans la liste des tansactions.", "success")
  end

  def send_message_request(email, object, sender, content)
    CustomerMailer.send_email(email, object, sender, content).deliver
  end

  def validate_profile_id
    if @profile_id.blank?
      @error_message << "Le profil ne peut pas être vide.<br />"
      @error = true
    end
  end

  def validate_message
    if @message.blank?
      @error_message << "Le contenu du message ne peut pas être vide.<br />"
      @error = true
      @status = "3" # Le message est vide
    end
  end

  def validate_email
    if @email.match(/^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i).blank?
      @error_message << "Veuillez entrer un email valide.<br />"
      @error = true
      @status = "2" # Le numéro de téléphone n'est pas valide
    end
  end

  def init_view
    @message_active = "active exp"
    @message_current_id = "current"
    @new_email_active_subclass = "this"

    @profiles = Profile.where("published IS NOT FALSE AND ((user_id IS NULL AND customer_id IS NULL) OR user_id IS NOT NULL) AND email IS TRUE")
  end

  def set_transaction(description, subscribers_count)
    @transaction = EmailTransaction.create(started_at: DateTime.now, profile_id: @profile.id, description: description, number_of_messages: subscribers_count, customer_id: current_user.id)
    #@transaction = SmsTransaction.create(started_at: DateTime.now, profile_id: @profile.id, description: description, number_of_messages: subscribers_count, sender_service: session[:service], service_id: @service_id)
  end

  # Make sure the user uploads an xls or xlsx file
  def validate_subscribers_email_file
    if @subscribers_file.blank? || (@subscribers_file.content_type != "application/vnd.ms-excel" && @subscribers_file.content_type != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      @error_message << "Veuillez choisir un fichier Excel contenant une liste d'emails.<br />"
      @error = true
    end
  end
end
