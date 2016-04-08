class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = User.all
  end
  def show
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to :back, :alert => "Access denied."
    end
  end
  def create
    if @user.valid?
      @gibbon = Rails.application.secrets.mailchimp_api_key
      @list_id = Rails.application.secrets.mailchimp_list_id
      @result = @gibbon.list(@list_id).members.create(
          body:{
              email_address: self.email,
              status: 'subscribed',
              merge_fields: {FNAME: self.first_name, LNAME: self.last_name}
          })
      Rails.logger.info("Subscribed #{self.email} to MailChimp") if @result
      flash[:notice] = "Signed up #{self.email}."
      redirect_to root_path
    else
      #render :new
    end
  end
  private
  def secure_params
    params.require(:@user).permit(:email)
  end
end