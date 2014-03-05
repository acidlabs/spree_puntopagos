module PuntoPagos
  Notification.class_eval do
    def valid? headers, params
      timestamp = get_timestamp headers
      message   = create_message params["token"], params["trx_id"], params["monto"].to_s, timestamp

      @verification = PuntoPagos::Verification.new(@env)
      @verification.verify(params["token"], params["trx_id"], params["monto"].to_i.to_s + ".00")
    end
  end
end