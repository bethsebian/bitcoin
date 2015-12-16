require 'openssl'
require 'base64'

class Wallet
  attr_reader :private_key, :public_key

  def initialize(path = "#{Dir.pwd}/.wallet" )
    @private_key = load_or_generate_private_key("#{path}/private_key.pem")
    @public_key = load_or_generate_public_key("#{path}/public_key.pem")
  end

  def load_or_generate_public_key(path)
    if File.exists?("#{path}/public_key.pem")
      OpenSSL::PKey.read(File.read(path))
    else
      @public_key = private_key.public_key
      File.write(path, public_key.to_pem)
      public_key
    end
  end

  def load_or_generate_private_key(path)
    if File.exists?(path)
      OpenSSL::PKey.read(File.read(path))
    elsif
      @private_key = OpenSSL::PKey::RSA.generate(2048)
      File.write(path, private_key.to_pem)
      private_key
    end
  end

  def sign_transaction(transaction_json)
    signature = @private_key.private_encrypt(transaction_json)
    hash_of_signature = Digest::SHA256.hexdigest(signature)
  end

  def gen(length)
    OpenSSL::PKey::RSA.generate(length)
  end

  def public_pem
    public_key.to_pem
  end
end