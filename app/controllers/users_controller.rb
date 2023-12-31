# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show destroy edit update]
  before_action :logged_in_user, only: %i[index edit update destroy]
  before_action :correct_user, only: %i[edit update]
  before_action :admin_user, only: %i[destroy]
  before_action :set_title

  def set_user
    @user = User.find(params[:id])
  end
  def set_title
    @title = 'Users'
  end

  def index
    # @users = User.all
    @users = User.where(activated: true)
                  .order(created_at: :desc)
                  .paginate(page: params[:page], per_page: USERS_PER_PAGE)
    # Rails.logger.debug("@users set in index: #{@users.inspect}")
  end

  def show
    @records = @user.records
    redirect_to root_url and return unless @user.activated?
    # debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.except(:avatar))
    if user_params[:avatar].present?
      @user.avatar.attach(user_params[:avatar])
    else
      # Using Rails.root to make sure the full path to the default avatar file is correct
      default_avatar_path = Rails.root.join('app', 'assets', 'images', 'avatar-1.jpg')
       # Using io: File.open to open the file and create an IO object to attach the file
      @user.avatar.attach(io: File.open(default_avatar_path), filename: 'avatar-1.jpg')
    end

    if @user.save
      """(It's able to check the demo mail in logs,
      click on the link after 'Click on the link below to activate your account')
      """
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      # reset_session
      # log_in @user
      # flash[:success] = "Welcome, #{@user.name}!"
      # redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    Rails.logger.debug('update-user')
    if user_params[:avatar].present?
      @user.avatar.attach(user_params[:avatar])
    end
    
    if @user.update(user_params)
      flash[:success] = "Profile was successfully updated."
      redirect_to @user
    else
      Rails.logger.debug('xxxxx-update-user')
      Rails.logger.debug(@user.errors.full_messages.join("\n"))
      render :edit, status: :unprocessable_entity
    end
  end



  def correct_user
    # current_user?() is the method defined in sessions_helper.rb
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end
  
  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin?
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User with id #{params[:id]} deleted"
    redirect_to users_url, status: :see_other
  end
  
  private

    # Remember not to add 'admin' attribute here, or something likes 
    # 'patch /users/5?admin=1' would be able to change user with id 5 to admin user.
    def user_params
      params.require(:user).permit(:name, :email, :avatar,
                       :password, :password_confirmation)
    end


  

end
