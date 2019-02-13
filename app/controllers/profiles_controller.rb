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
    subscribers_array = []

    validate_creation_params

    if @error
      init_view
      params[:name] = params[:name]
      @error_message = messages!(@error_message, "error")

      render :new
    else
      profile = current_user.profiles.create(name: @label)
      @spreadsheet = Spreadsheet.open(@subscribers_file.path).worksheet(0)
      @spreadsheet.each do |row|
        subscribers_array << {profile_id: profile.id, col1: row[0].to_s, col2: row[1], col3: row[2], col4: row[3], col5: row[4], col6: row[5], col7: row[6], col8: row[7], col9: row[8], col10: row[9]}
      end
      ProfileData.create(subscribers_array)

      redirect_to finalize_message_profile_path(profile_id: profile.id)
    end
  end

  def finalize
    @profile = Profile.find_by_id(params[:profile_id])
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

  def init_view
    @settings_active = "active exp"
    @profile_current_id = "current"
    @new_profile_active_subclass = "this"
  end
end
