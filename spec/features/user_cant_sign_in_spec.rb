require 'rails_helper'

# If you use js: true you must sleep to wait for the emails to arrive
feature "User can't sign in", js: true do
  context "problems finding log in user" do
    before(:each) do
      visit '/'
    end

    scenario "email unknown" do
      complete_login_username_or_email_screen('bob@bob.com')
      expect(page).to have_content(t :"sessions.new.unknown_email")
      screenshot!
    end

    scenario "username unknown" do
      complete_login_username_or_email_screen('bob')
      expect(page).to have_content(t :"sessions.new.unknown_username")
      screenshot!
    end

    scenario "username or email blank" do
      complete_login_username_or_email_screen('')
      expect(page).to have_content("Email or username can't be blank") # TODO put in en.yml and reverse username/email
      screenshot!
    end

    scenario "multiple accounts match email" do
      email_address = 'user@example.com'
      user1 = create_user 'user1'
      email1 = create_email_address_for(user1, email_address)
      user2 = create_user 'user2'
      email2 = create_email_address_for(user2, 'user-2@example.com')
      ContactInfo.where(id: email2.id).update_all(value: email1.value)

      complete_login_username_or_email_screen(email_address)
      expect(page).to have_content(t(:"sessions.new.multiple_users.content_html").split('.')[0])

      screenshot!

      click_link t(:"sessions.new.multiple_users.click_here")
      expect(page).to have_content(
        ActionView::Base.full_sanitizer.sanitize(
          t(:"sessions.new.sent_multiple_usernames", email: email_address)
        )
      )

      screenshot!

      expect(page.first('input')["placeholder"]).to eq t(:"sessions.new.username_placeholder")
      expect(page.first('input').text).to be_blank

      open_email(email_address)
      expect(current_email).to have_content('used on more than one')
      expect(current_email).to have_content('user1 and user2')
      capture_email!

      complete_login_username_or_email_screen('user2')
      expect_authenticate_page
    end

    scenario "multiple accounts match email but no usernames" do
      # For a brief window in 2017 users could sign up with jimbo@gmail.com and Jimbo@gmail.com
      # and also not have a username.  So the "you can't sign in with email you must use your
      # username" approach won't work for them.  We need to give them some other "contact support"
      # message.
      email_address = 'user@example.com'
      user1 = create_user 'user1'
      email1 = create_email_address_for(user1, email_address)
      user2 = create_user 'user2'
      email2 = create_email_address_for(user2, 'temporary@email.com')
      ContactInfo.where(id: email2.id).update_all(value: 'UsEr@example.com')
      user2.update_attribute(:username, nil)
      user1.update_attribute(:username, nil)

      # Can't be an exact email match to trigger this scenario
      complete_login_username_or_email_screen('useR@example.com')
      expect(page).to have_content(t(:"sessions.new.multiple_users_missing_usernames.content_html").split('.')[0])

      expect(page.all('a')
                 .select{|link| link.text == t(:"sessions.new.multiple_users_missing_usernames.help_link_text")}
                 .first["href"]).to eq "mailto:info@openstax.org"

      screenshot!
    end
  end

  context "we find one user", js: true do
    before(:each) do
      @user = create_user 'user'
      @email = create_email_address_for @user, 'user@example.com'
      arrive_from_app
    end

    scenario "just has password auth" do
      complete_login_username_or_email_screen('user@example.com')

      complete_login_password_screen('wrongpassword')
      expect(page).to have_content(t :"controllers.sessions.incorrect_password")
      screenshot!

      click_link(t :"sessions.authenticate_options.reset_password")
      expect(page).to have_content(t(:'identities.send_reset.we_sent_email', emails: 'user@example.com'))
      screenshot!

      open_email('user@example.com')
      expect(current_email).to have_content("Click here to reset")
      capture_email!

      password_reset_path = get_path_from_absolute_link(current_email, 'a')
      visit password_reset_path
      screenshot!

      complete_reset_password_screen
      screenshot!
      complete_reset_password_success_screen

      expect_back_at_app
    end

    scenario "just has social auth" do
      @user.identity.destroy
      password_authentication = @user.authentications.first
      FactoryGirl.create :authentication, provider: 'google_oauth2', user: @user
      password_authentication.destroy

      complete_login_username_or_email_screen('user@example.com')
      screenshot!

      # TODO somehow simulate oauth failure so we see error message

      click_link(t :"sessions.authenticate_options.add_password")
      expect(page).to have_content(t(:'identities.send_add.we_sent_email', emails: 'user@example.com'))
      screenshot!

      open_email('user@example.com')
      expect(current_email).to have_content("Click here to add")
      capture_email!

      password_add_path = get_path_from_absolute_link(current_email, 'a')
      visit password_add_path
      screenshot!

      expect(@user.identity(true)).to be_nil

      complete_add_password_screen
      screenshot!
      complete_add_password_success_screen

      expect(@user.identity(true)).not_to be_nil
      expect(@user.authentications(true).map(&:provider)).to contain_exactly(
        "google_oauth2", "identity"
      )

      expect_back_at_app
    end

    scenario "has both password and social auths" do
      FactoryGirl.create :authentication, provider: 'google_oauth2', user: @user
      complete_login_username_or_email_screen('user@example.com')
      expect(page).to have_content(t :"sessions.authenticate_options.reset_password")
      screenshot!
    end
  end

end
