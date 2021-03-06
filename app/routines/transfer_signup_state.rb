class TransferSignupState

  lev_routine

  def exec(signup_state:, user:)
    fatal_error(code: :no_signup_email) if signup_state.nil?
    fatal_error(code: :not_verified) if !signup_state.verified?

    run(AddEmailToUser, signup_state.contact_info_value, user, {already_verified: true})

    user.role = signup_state.role
    user.save
    transfer_errors_from(user, {type: :verbatim}, true)

    signup_state.destroy
    transfer_errors_from(signup_state, {type: :verbatim}, true)
  end
end
