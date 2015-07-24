require 'spec_helper'

describe 'accounts:create_admin' do
  let!(:username) { SecureRandom.hex(4) }
  let!(:create_admin) { Rake::Task['accounts:create_admin'] }

  # the rake task is considered "already invoked" in the second test and just
  # returns without running the code, "reenable" sets the "already invoked"
  # flag to false again
  before { create_admin.reenable }

  context 'when provided with just a username' do
    it 'creates an admin user with the username as the password' do
      expect {
        create_admin.invoke(username)
      }.to change { User.count }.by(1)
      user = User.where { username == my { username } }.first
      expect(user.is_administrator).to be true
      expect(user.identity.authenticate(username)).to eq user.identity
      expect(user.authentications.first.provider).to eq 'identity'
    end
  end

  context 'when provided with a username and a password' do
    it 'creates an admin user with the specified password' do
      expect {
        create_admin.invoke(username, 'password')
      }.to change { User.count }.by(1)
      user = User.where { username == my { username } }.first
      expect(user.is_administrator).to be true
      expect(user.identity.authenticate('password')).to eq user.identity
      expect(user.authentications.first.provider).to eq 'identity'
    end
  end
end
