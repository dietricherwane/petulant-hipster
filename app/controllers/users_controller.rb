class UsersController < ApplicationController

  include MessagesHelper

  layout "administrator"

  def edit
    @user = current_user
  end

  def update
    if !params[:firstname].blank? && !params[:lastname].blank?
      @user = current_user.update_attributes(firstname: params[:firstname], lastname: params[:lastname])
      flash.now[:error] = "Les informations ont été modifiées"
      @success_message = messages!("Les informations ont été modifiées", "success")
    else
      @error_message = messages!("Le nom et les Prénoms doivent être renseignés", "error")
    end

    render :edit
  end

end
