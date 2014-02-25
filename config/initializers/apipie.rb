Apipie.configure do |config|
  config.app_name                = "#{SITE_NAME} API"
  config.api_base_url            = "/api"
  config.doc_base_url            = "/api/docs"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
  config.copyright               = OpenStax::Utilities::Text.copyright('2013', COPYRIGHT_HOLDER)
  config.layout                  = 'application_body_api_docs'
  config.markup                  = Apipie::Markup::Markdown.new
  config.namespaced_resources    = false

  # Ok this is one of the uglier things I have ever done in code.  To get Apipie to 
  # render nicely inside the layout specified above, it needs to know about some helper
  # methods used in that layout.  It would seem that to tell the Apipie controllers about
  # these helper methods would be as simple as extending the ApipiesController as in:
  #
  #   Apipie::ApipiesController.class_eval do
  #     helper_method :current_user, :current_user=, :signed_in?, :sign_in, :sign_out!
  #   end
  #
  # Typically we'd put this in an initializer or some lib file.
  #
  # This works except that in development, Apipie reloads a ton of controllers to make
  # sure that generated API documentation reflects the latest changed state of the 
  # application controller code.  If it didn't reload this code, developers would have
  # to restart the server for Apipie to generate updated documentation. When the reload
  # happens, a class_eval call like the one above gets wiped out -- the result is that
  # in development Apipie pages load fine once, but then puke on future loads.  One 
  # hack would be to put the code above in a file that gets reloaded by Apipie (e.g.
  # the ApplicationController); however, this seems to only work on page loads after
  # the first one.  
  #
  # The only real hook we have into Apipie is the authenticate Proc.  We use it here
  # to set the helper_methods if they don't yet exist.  So this hack is ugly because
  # I'm using "authenticate" in a way not intended and I'm using an attribute,
  # "_helper_methods", that appears intended to be private.  In development, the helper
  # methods will never be set, and the class_eval will do it.  In production, they 
  # should be set after the first call.
  #
  # The real solution is to fork Apipie and get it to support helper_method set in 
  # config.  Maybe we'll do that.  I added an issue on Apipie to get the ball rolling:
  # https://github.com/Apipie/apipie-rails/issues/210
  #
  config.authenticate = Proc.new {
    return if self._helper_methods.include?(:current_user)
    class_eval { helper_method :current_user, :current_user=, :signed_in?, :sign_in, :sign_out! }
  }
end
