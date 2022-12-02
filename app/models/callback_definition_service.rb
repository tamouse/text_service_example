# frozen_string_literal: true

class CallbackDefinitionService
  # All this nonesense is necessary just to be able run in dev, test, and prod

  attr_reader :webhook_uri
  
  def self.callback
    new.callback
  end

  def callback
    host     = get_callback_host
    scheme   = host.starts_with?('localhost') ? 'http' : 'https'
    userinfo = nil
    port     = '3000' if host.starts_with?('localhost')
    registry = nil
    path     = webhook_site? ? webhook_uri.path : webhook_path
    opaque   = nil
    query    = nil
    fragment = nil

    # scheme, userinfo, host, port, registry, path, opaque, query, fragment, parser = DEFAULT_PARSER, arg_check = false
    callback_uri = URI.for(scheme, userinfo, host, port, registry, path, opaque, query, fragment)

    callback_uri.to_s
  end

  private

  def get_callback_host
    if Rails.env.development? || Rails.env.test?
      if ngrok?
        ENV['LOCAL_TUNNEL_HOST']
      elsif webhook_site?
        webhook_uri.host
      else
        URI(root_url).host
      end
    else
      URI(root_url).host
    end
  end

  def ngrok?
    !!ENV['LOCAL_TUNNEL_HOST']
  end

  def webhook_site?
    return false unless ENV['WEBHOOK_SITE']
    
    @webhook_uri ||= URI.parse(ENV['WEBHOOK_SITE'])
  end
    
  def webhook_path
    Rails.application.routes.url_helpers.webhook_path
  end

  def root_url
    Rails.application.routes.url_helpers.root_url(host: 'localhost', port: 3000)
  end
end
