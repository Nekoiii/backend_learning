require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    # Clears the array storing sent emails in Action Mailer.
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "xx@xxx",
                                         password: "xxxxxx",
                                         password_confirmation: "aaaaaa" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'
  end

  test "valid signup information account activation" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "AA",
                                         email: "aa@123.aa",
                                         password: "aaaaaa",
                                         password_confirmation: "aaaaaa" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    # follow_redirect!
    # assert_template 'users/show'
    # assert_not flash.empty?
    # assert is_logged_in?

  end
end


class AccountActivationTest < UsersSignup

  def setup
    super
      post users_path, params: { user: { name:  "AA",
                                         email: "aa@123.aa",
                                         password: "aaaaaa",
                                         password_confirmation: "aaaaaa" } }
    @user = assigns(:user)
  end

  test "should not be activated" do
    assert_not @user.activated?
  end

  test "should not be able to log in before account activation" do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test "should not be able to log in with invalid activation token" do
    get edit_account_activation_path("invalid token", email: @user.email)
    assert_not is_logged_in?
  end

  test "should not be able to log in with invalid email" do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  test "should log in successfully with valid activation token and email" do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
