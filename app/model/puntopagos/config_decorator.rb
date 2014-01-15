module PuntoPagos
  Config.class_eval do
    @@env    = ''
    @@key    = ''
    @@secret = ''

    def self.env= new_env
      @@env = new_env.to_sym
    end

    def self.key= new_key
      @@key = new_key
    end

    def self.secret= new_secret
      @@secret = new_secret
    end

    def initialize env = nil, config_override = nil
      @puntopagos_base_url = ::PuntoPagos::Config::PUNTOPAGOS_BASE_URL[@@env]
      @puntopagos_key = @@key
      @puntopagos_secret = @@secret
    end
  end
end