class ProfilesController < ApplicationController
  include MessagesHelper

  layout "administrator"

  def new
    init_view
  end

  def create
    @label = params[:name]
    @subscribers_file = params[:post][:subscribers_file] rescue nil
    @error = false
    @error_message = ""
    init_view

    validate_creation_params

    if @error
      params[:name] = params[:name]
      @error_message = messages!(@error_message, "error")

      render :new
    else
      parameter = Parameter.first
      @spreadsheet = Spreadsheet.open(@subscribers_file.path).worksheet(0)
      number_of_columns = @spreadsheet.rows.max_by(&:size).count
      profile = current_user.profiles.create(name: @label, number_of_columns: number_of_columns, aliases: create_profile_header(number_of_columns))
      data_array = []

      @spreadsheet.each do |row|
        i = 0
        row_data = ""
        while i < number_of_columns
          row_data << %Q[#{row[i]}#{parameter.profile_separator}]
          i += 1
        end
        data_array << {profile_id: Profile.find_by_name(@label).id, row_content: row_data[0..-(parameter.profile_separator.length)]}
      end
      ProfileData.create(data_array)

      redirect_to administrator_finalize_message_profile_path(profile_id: profile.id)
    end
  end

  def update
    init_view
    @profile = Profile.find_by_id(params[:profile_id])
    parameter = Parameter.first
    @sample_data = ProfileData.where("profile_id = #{@profile.id}").first.row_content.split(parameter.profile_separator)
    @aliases = ""

    i = 0
    while i < @profile.number_of_columns
      @aliases << (params["alias#{i}".to_sym]  rescue "") + parameter.profile_separator
      i += 1
    end

    if valid_aliases?
      msisdn_column_number = @aliases.split(parameter.profile_separator).index("MSISDN")
      @profile.update_attributes(aliases: @aliases, msisdn_column: msisdn_column_number)
      @success_message = messages!("Les alias ont été mis à jour", "success")
    else
      @error_message = messages!("Veuillez sélectionner une seule colonne contenant le MSISDN", "error")
    end
    @aliases = @profile.aliases.split(parameter.profile_separator) rescue Array.new(7)

    render :finalize
  end

  def valid_aliases?
    number_of_msisdn_occurence = @aliases.scan(/(?=MSISDN)/).count
    number_of_msisdn_occurence != 1 ? false : true
  end

  def list
    @profile_active = "active exp"
    @profile_current_id = "current"
    @list_profile_active_subclass = "this"

    @profiles = Profile.where("user_id = #{current_user.id}").order("id ASC").page(params[:page])
  end

  def disable
    disble_enable(params[:profile_id], false, "désactivé")
  end

  def enable
    disble_enable(params[:profile_id], true, "activé")
  end

  def disble_enable(profile_id, status, status_text)
    @profiles = Profile.where("user_id = #{current_user.id}").order("id ASC").page(params[:page])
    @profile = Profile.where("id = #{profile_id}").first rescue nil
    @profile_active = "active exp"
    @profile_current_id = "current"
    @list_profile_active_subclass = "this"

    if @profile.blank?
      @error_message = messages!("Le profil n'a pas été trouvé", "error")
    else
      @profile.update_attributes(published: status)
      @success_message = messages!("Le profil a été correctement #{status_text}", "success")
    end

    render :list
  end

  def create_profile_header(number_of_columns)
    headers = Array.new(number_of_columns)
    i = 0
    while i < number_of_columns
      headers[i] = "Colonne #{i}"
      i += 1
    end

    return headers.join("|")
  end

  def finalize
    init_view
    parameter = Parameter.first
    @profile = Profile.find_by_id(params[:profile_id])
    @aliases = @profile.aliases.split(parameter.profile_separator) rescue Array.new(7)
    @sample_data = ProfileData.where("profile_id = #{@profile.id}").first.row_content.split(parameter.profile_separator)
    @success_message = messages!("Veuillez sélectionner la colonne dans laquelle se trouve le MSISDN", "notice")
  end

  def validate_creation_params
    if @label.blank?
      @error = true
      @error_message << "Veuillez renseigner un libellé pour le profil.<br />"
    end
    if !Profile.where("name = ? AND user_id = #{current_user.id}", @label).blank?
      @error = true
      @error_message << "Ce libellé existe déjà. Veuillez en utiliser un autre.<br />"
    end
    if @subscribers_file.blank? || (@subscribers_file.content_type != "application/vnd.ms-excel" && @subscribers_file.content_type != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      @error = true
      @error_message << "Veuillez choisir un fichier Excel contenant une liste de numéros.<br />"
    end
  end

  def new_email
    init_email_view
    @new_profile_email_active_subclass = "this"
  end

  def create_email
    @label = params[:name]
    @subscribers_file = params[:post][:subscribers_file] rescue nil
    @error = false
    @error_message = ""
    init_email_view

    validate_email_creation_params

    if @error
      params[:name] = params[:name]
      @error_message = messages!(@error_message, "error")

      render :new
    else
      parameter = Parameter.first
      @spreadsheet = Spreadsheet.open(@subscribers_file.path).worksheet(0)
      number_of_columns = @spreadsheet.rows.max_by(&:size).count
      profile = current_user.profiles.create(name: @label, number_of_columns: number_of_columns, aliases: create_profile_header(number_of_columns), email: true)
      data_array = []
      profile = Profile.where("name = ? AND email IS TRUE", @label).first

      @spreadsheet.each do |row|
        i = 0
        row_data = ""
        while i < number_of_columns
          row_data << %Q[#{row[i]}#{parameter.profile_separator}]
          i += 1
        end
        data_array << {profile_id: profile.id, row_content: row_data[0..-(parameter.profile_separator.length)]}
      end
      ProfileData.create(data_array)

      redirect_to administrator_finalize_email_profile_path(profile_id: profile.id)
    end
  end

  def finalize_email
    init_email_view
    parameter = Parameter.first
    @profile = Profile.find_by_id(params[:profile_id])
    @aliases = @profile.aliases.split(parameter.profile_separator) rescue Array.new(7)
    @sample_data = ProfileData.where("profile_id = #{@profile.id}").first.row_content.split(parameter.profile_separator)
    @success_message = messages!("Veuillez sélectionner la colonne dans laquelle se trouve l'email", "notice")
    @new_profile_email_active_subclass = "this"
  end

  def list_email
    init_email_view
    @list_profile_email_active_subclass = "this"
    @profiles = Profile.where("user_id = #{current_user.id} AND email IS TRUE").order("id ASC").page(params[:page])
  end

  def email_disable
    disble_enable_email(params[:profile_id], false, "désactivé")
  end

  def email_enable
    disble_enable_email(params[:profile_id], true, "activé")
  end

  def disble_enable_email(profile_id, status, status_text)
    @profiles = Profile.where("user_id = #{current_user.id} AND email IS TRUE").order("id ASC").page(params[:page])
    @profile = Profile.where("id = #{profile_id}").first rescue nil
    @profile_active = "active exp"
    @profile_current_id = "current"
    @list_profile_active_subclass = "this"

    if @profile.blank?
      @error_message = messages!("Le profil n'a pas été trouvé", "error")
    else
      @profile.update_attributes(published: status)
      @success_message = messages!("Le profil a été correctement #{status_text}", "success")
    end

    render :list_email
  end

  def update_email
    init_email_view
    @profile = Profile.find_by_id(params[:profile_id])
    parameter = Parameter.first
    @sample_data = ProfileData.where("profile_id = #{@profile.id}").first.row_content.split(parameter.profile_separator)
    @aliases = ""

    i = 0
    while i < @profile.number_of_columns
      @aliases << (params["alias#{i}".to_sym]  rescue "") + parameter.profile_separator
      i += 1
    end

    if valid_email_aliases?
      email_column_number = @aliases.split(parameter.profile_separator).index("EMAIL")
      @profile.update_attributes(aliases: @aliases, email_column: email_column_number)
      @success_message = messages!("Les alias ont été mis à jour", "success")
    else
      @error_message = messages!("Veuillez sélectionner une seule colonne contenant l'email", "error")
    end
    @aliases = @profile.aliases.split(parameter.profile_separator) rescue Array.new(7)

    render :finalize_email
  end

  def valid_email_aliases?
    number_of_email_occurence = @aliases.scan(/(?=EMAIL)/).count
    number_of_email_occurence != 1 ? false : true
  end

  def validate_email_creation_params
    if @label.blank?
      @error = true
      @error_message << "Veuillez renseigner un libellé pour le profil.<br />"
    end
    if !Profile.where("name = ? AND user_id = #{current_user.id} AND email IS TRUE", @label).blank?
      @error = true
      @error_message << "Ce libellé existe déjà. Veuillez en utiliser un autre.<br />"
    end
    if @subscribers_file.blank? || (@subscribers_file.content_type != "application/vnd.ms-excel" && @subscribers_file.content_type != "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      @error = true
      @error_message << "Veuillez choisir un fichier Excel contenant une liste d'emails.<br />"
    end
  end

  def create_profile_header(number_of_columns)
    headers = Array.new(number_of_columns)
    i = 0
    while i < number_of_columns
      headers[i] = "Colonne #{i}"
      i += 1
    end

    return headers.join("|")
  end

  def init_email_view
    @profile_active = "active exp"
    @profile_current_id = "current"
  end

  def init_view
    @settings_active = "active exp"
    @profile_current_id = "current"
    @new_profile_active_subclass = "this"
  end
end
