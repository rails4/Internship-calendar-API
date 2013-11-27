module SecureConnection
  def ensure_ssl!
    error 403 unless request.secure?
  end
end
