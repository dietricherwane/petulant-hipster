class MessagesController < ApplicationController
  include MessagesHelper

  before_action :init_messages, only: [:send_message, :api_send_message, :filter_api_send_message]
  prepend_before_filter :authenticate_user!, except: [:api_send_message, :filter_api_send_message, :api_md5_encrypt]

  layout "administrator"

  def new
    init_message_view
  end

  def send_message
    @profile_id = params[:post][:profile_id]
    @message = params[:post][:message]
    @number = params[:post][:custom_number]
    @subscribers_file = params[:post][:subscribers_file]
    @error = false

    validate_profile_id
    validate_message

    unless @error
      @profile = Profile.find_by_id(@profile_id)
      @service = "Paymoney"
      if @profile
        if @profile.name == "Numéro unique"
          validate_custom_number
        end
        if @profile.name == "Liste de numéros"
          validate_subscribers_file
        end
      end
    end

    unless @error
      @sent_messages = 0
      @failed_messages = 0
      deliver_messages
    end

    init_message_view

    @error_message = messages!(@error_message, "error")

    render :new
  end

  def filter_api_send_message
    @authentication_token = "0d1773a649e4c88bff44c49ec154615c"
    @message = params[:message]
    @number = params[:msisdn]
    @login = params[:login]
    @password = params[:password]
    @sender = params[:sender]
    @service_id = params[:service_id]
    @service = Customer.where("login = ? AND password = ? AND service_id = ?", @login, @password[14, @password.length], @service_id).first.label rescue ""

    CustomLog.create(sender_service: "#{@service} | #{@login.to_s} | #{@password.to_s}", message: params[:message], msisdn: params[:msisdn])

    if @login.blank? && @password.blank? && @service.blank?
      api_send_message
    else
      if !@service.blank?
        api_send_message
      else
        render text: aes256_encrypt("ngser", @password[14, @password.length])#"4"
      end
    end
  end

  def api_send_message
    @profile = Profile.find_by_name("Numéro unique")
    @error = false
    @status = "0"


    if @authentication_token == "0d1773a649e4c88bff44c49ec154615c"
      validate_custom_number
      validate_message
    else
      @error = true
    end

    unless @error
      @sent_messages = 0
      @failed_messages = 0
      deliver_messages
    end

    render text: @status
  end

  def deliver_messages
    if @profile.name == "Numéro unique"
      set_transaction("Envoi de message à un numéro.", 1)
      send_message_request(@number.split.first)
      @transaction.update_attributes(ended_at: DateTime.now, send_messages: @sent_messages, failed_messages: @failed_messages)

      @success_message = messages!("Le message a été envoyé. Veuillez consulter l'état de l'envoi dans la liste des tansactions.", "success")
    end

    if @profile.name == "Liste de numéros"
      set_transaction("Envoi de message à une liste de numéros.", 0)
      deliver_message_to_excel_list
      puts "**************deliver to excel list"
    end
  end

  def set_transaction(description, subscribers_count)
    @transaction = SmsTransaction.create(started_at: DateTime.now, profile_id: @profile.id, description: description, number_of_messages: subscribers_count, sender_service: session[:service])
  end



  def deliver_message_to_excel_list
    puts "entering thread"
    #Thread.new do
      @spreadsheet = Spreadsheet.open(@subscribers_file.path).worksheet(0)
      puts "sheet opened"
      @spreadsheet.each do |row|
        msisdn = row[0].to_s
        puts msisdn
        unless not_a_number?(msisdn) or msisdn.length < 11
          send_message_request(msisdn[-11,11])
        end
      end
      @transaction.update_attributes(ended_at: DateTime.now, send_messages: @sent_messages, failed_messages: @failed_messages, number_of_messages: (@sent_messages + @failed_messages))
      if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
        ActiveRecord::Base.connection.close
      end
    #end
    @success_message = messages!("Veuillez consulter l'état de l'envoi dans la liste des tansactions.", "success")
  end

  def send_message_job(subscribers)
    subscribers.each do |subscriber|
      @subscriber = subscriber
      send_message_request(@subscriber.msisdn)
    end
    @transaction.update_attributes(ended_at: DateTime.now, send_messages: @sent_messages, failed_messages: @failed_messages)
  end

  def send_message_request(msisdn)
    if msisdn.match(/\./)
      msisdn = "22" + msisdn[0..8]
    end
    request = Typhoeus::Request.new("http://smsplus3.routesms.com:8080/bulksms/bulksms?username=ngser1&password=abcd1234&type=0&dlr=1&destination=#{msisdn}&source=#{@sender}&message=#{URI.escape(@message)}", followlocation: true, method: :get)

    request.on_complete do |response|
      if response.success?
        result = response.body.strip.split("|") rescue nil
        if result[0] == "1701"
          @status = "1"
          @sent_messages += 1
          @transaction.message_logs.create(subscriber_id: (@subscriber.id rescue nil), msisdn: msisdn, profile_id: (@subscriber.profile_id rescue nil), period_id: (@subscriber.period_id rescue nil), message: @message, status: result[0], message_id: result[2])
        else
          #@status = "0"
          @status = "6"
          @failed_messages += 1
          @transaction.message_logs.create(subscriber_id: (@subscriber.id rescue nil), msisdn: msisdn, profile_id: (@subscriber.profile_id rescue nil), period_id: (@subscriber.period_id rescue nil), message: @message, status: result[0])
        end
      end
    end

    request.run
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

  def validate_custom_number
    if @number.blank? || not_a_number?(@number) || (@number.length != 11)
      @error_message << "Veuillez entrer un numéro de téléphone valide.<br />"
      @error = true
      @status = "2" # Le numéro de téléphone n'est pas valide
    end
  end

  # Make sure the user uploads an xls or xlsx file
  def validate_subscribers_file
    if @subscribers_file.blank? || (@subscribers_file.content_type != "application/vnd.ms-excel" && @subscribers_file.content_type != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      @error_message << "Veuillez choisir un fichier Excel contenant une liste de numéros.<br />"
      @error = true
    end
  end

  def init_messages
    @error_message = ""
    @success_message = ""
  end

  def init_message_view
    @message_active = "active exp"
    @message_current_id = "current"
    @new_message_active_subclass = "this"

    @profiles = Profile.where("published IS NOT FALSE")
  end

  def api_md5_encrypt
    status = Customer.find_by_service_id(params[:service_id]).update_attributes(password: Digest::MD5.hexdigest(params[:password])).blank? ? "Echec" : "Succès"
    render text: %Q[
      {"status":"#{status}"}
    ]
  end
end
