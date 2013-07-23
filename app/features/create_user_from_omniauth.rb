

class CreateUserFromOmniauth

  def exec(auth)
    case auth.provider
    when "facebook"
      create_from_facebook_auth(auth)
    when "identity"
      create_from_identity_auth(auth)
    else
      raise IllegalArgument, "unknown auth provider: #{auth.provider}"
    end
  end

protected

  def create_from_identity_auth(auth)
    User.create! do |user|
      user.username = SecureRandom.hex(10)
    end
  end

  def create_from_facebook_auth(auth)
    User.create! do |user|
      user.username = auth['info']['nickname']
    end
  end

end