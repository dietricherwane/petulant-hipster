class CustomerMessagesController < ApplicationController
  require "base64"
  include MessagesHelper

  before_action :init_messages, only: [:send_message, :api_send_message, :filter_api_send_message]
  #prepend_before_filter :authenticate_user!, except: [:api_send_message, :filter_api_send_message, :api_bulk, :api_md5_encrypt]

  layout "customer"

  def new
    init_message_view
  end

  def init_message_view
    @message_active = "active exp"
    @message_current_id = "current"
    @new_message_active_subclass = "this"

    @profiles = Profile.where("published IS NOT FALSE")
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
      @service = session[:customer]
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

  def deliver_messages
    if @profile.name == "Numéro unique"
      if session[:customer].bulk.to_i > 0
        set_transaction("Envoi de message à un numéro.", 1)
        send_message_request(@number.split.first)
        @transaction.update_attributes(ended_at: DateTime.now, send_messages: @sent_messages, failed_messages: @failed_messages, user_id: (@service.user.id rescue nil))
        @success_message = messages!("Le message a été envoyé. Veuillez consulter l'état de l'envoi dans la liste des tansactions.", "success")
      else
        @error_message = messages!("Vous n'avez plus de SMS. Votre message n'a pas pu être envoyé.", "error")
      end
    end

    if @profile.name == "Liste de numéros"
      set_transaction("Envoi de message à une liste de numéros.", 0)
      deliver_message_to_excel_list
    end
  end

  def set_transaction(description, subscribers_count)
    @transaction = SmsTransaction.create(started_at: DateTime.now, profile_id: @profile.id, description: description, number_of_messages: subscribers_count, sender_service: @sender, service_id: @service_id)
    #@transaction = SmsTransaction.create(started_at: DateTime.now, profile_id: @profile.id, description: description, number_of_messages: subscribers_count, sender_service: session[:service], service_id: @service_id)
  end

  def deliver_message_to_excel_list
    puts "entering thread"
    #Thread.new do
      @spreadsheet = Spreadsheet.open(@subscribers_file.path).worksheet(0)
      puts "sheet opened"
      @spreadsheet.each do |row|
        msisdn = row[0].to_s
        unless not_a_number?(msisdn) or msisdn.length < 11
          if session[:customer].bulk.to_i > 0
            send_message_request(msisdn[-11,11])
          end
        end
      end
      @transaction.update_attributes(ended_at: DateTime.now, send_messages: @sent_messages, failed_messages: @failed_messages, number_of_messages: (@sent_messages + @failed_messages))
      if (ActiveRecord::Base.connection && ActiveRecord::Base.connection.active?)
        ActiveRecord::Base.connection.close
      end
    #end
    @success_message = messages!("Veuillez consulter l'état de l'envoi dans la liste des tansactions.", "success")
  end

  def send_message_request(msisdn)
    if msisdn.match(/\./)
      msisdn = "22" + msisdn[0..8]
    end
    parameter = Parameter.first

    #if @service.bulk.blank? or @service.bulk == 0

    #else
      case (@service.sms_provider.name rescue nil)
      when "BICS"
        send_with_bics(parameter, msisdn, @sender, @message)
      when "ROUTESMS"
        send_with_routesms(parameter, msisdn, @sender, @message)
      when "INFOBIP"
        send_with_infobip(parameter, msisdn, @sender, @message)
      else
        send_with_infobip(parameter, msisdn, @sender, @message)#send_with_routesms(parameter, msisdn, @sender, @message)
      end

      if @status == "1"
        @status = "1"
        @sent_messages += 1
        @transaction.message_logs.create(subscriber_id: (@subscriber.id rescue nil), msisdn: msisdn, profile_id: (@subscriber.profile_id rescue nil), period_id: (@subscriber.period_id rescue nil), message: @message, status: @request_status, message_id: @message_id, customer_id: (@service.id rescue nil), user_id: (@service.user.id rescue nil))
        # Décrémentation du compteur de SMS
        session[:customer].update_attributes(bulk: (@service.bulk.to_i rescue nil) - 1) rescue nil
      else
        #@status = "6"
        @failed_messages += 1
        @transaction.message_logs.create(subscriber_id: (@subscriber.id rescue nil), msisdn: msisdn, profile_id: (@subscriber.profile_id rescue nil), period_id: (@subscriber.period_id rescue nil), message: @message, status: @request_status, customer_id: (@service.id rescue nil), user_id: (@service.user.id rescue nil))
      end
    #end
  end

  def send_with_bics(parameter, msisdn, sender, message)
    sms_provider_url = parameter.sms_provider_url rescue ''
    sms_provider_token = parameter.sms_provider_token_ext rescue ''
    body = %Q[
      {
        "outboundSMSMessageRequest": {
            "address": ["tel:+#{msisdn}"],
            "senderAddress": "tel:#{sender}",
            "outboundSMSTextMessage": {"message": "#{message}"},
            "senderName": "NGSER"
        }
      }
    ]
    request = Typhoeus::Request.new(sms_provider_url + "/outbound/#{URI.escape(sender)}/requests", body: body, followlocation: true, method: :post, headers: { Authorization: "Bearer #{sms_provider_token}", 'Content-Type'=> "application/json" })
    request.run
    result = request.response.body.strip rescue nil
    @request_status = JSON.parse(result)["outboundSMSMessageRequest"]["deliveryInfoList"]["deliveryInfo"].first["deliveryStatus"] rescue nil
    if @request_status == "DeliveredToNetwork"
      @status = "1"
      @message_id = JSON.parse(result)["outboundSMSMessageRequest"]["resourceURL"]
    else
      @status = "6"
    end
  end

  def send_with_infobip(parameter, msisdn, sender, message)
    sms_provider_url = parameter.infobip_provider_url rescue ''
    auth_header = Base64.encode64(parameter.infobip_provider_username + ":" + parameter.infobip_provider_password) rescue ''
    result = RestClient.post sms_provider_url, {'from' => "#{sender}", 'to' => "#{msisdn}", 'text' => "#{message}"}.to_json, {content_type: :json, accept: :json, :Authorization => "Basic #{auth_header}"} rescue nil
    @request_status = JSON.parse(result)["messages"].first["status"]["groupName"] #rescue nil
    if @request_status == "ACCEPTED" || @request_status == "PENDING"
      @status = "1"
      @message_id = JSON.parse(result)["messages"].first["messageId"]
    else
      @status = "6"
    end
  end

  def send_with_routesms(parameter, msisdn, sender, message)
    request = Typhoeus::Request.new(parameter.routesms_provider_url + "?username=#{parameter.routesms_provider_username}&password=#{parameter.routesms_provider_password}&type=0&dlr=1&destination=#{msisdn}&source=#{URI.escape(sender)}&message=#{URI.escape(message)}", followlocation: true, method: :get)
    request.run
    result = request.response.body.strip.split("|") rescue nil
    @request_status = result[0]
    if @request_status == "1701"
      @status = "1"
      @message_id = result[2]
    else
      @status = "6"
    end
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
end
