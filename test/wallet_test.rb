require_relative 'wallet'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

class WalletTest < Minitest::Test

  def test_it_creates_a_private_key
    key = Wallet.new.gen(2048)

    assert_equal 'OpenSSL::PKey::RSA', key.class.to_s
  end

  def test_it_initializes_with_a_private_key
    key = Wallet.new

    assert_equal 'OpenSSL::PKey::RSA', key.private_key.class.to_s
  end

  def test_it_initializes_with_a_public_key
    key = Wallet.new

    assert_equal 'OpenSSL::PKey::RSA', key.public_key.class.to_s
  end

  def test_private_key_encrypts_message
    key = Wallet.new

    priv_encrypted_message = key.private_key.private_encrypt("pear")

    assert_equal String, priv_encrypted_message.class
  end

  def test_public_key_decrypts_private_key_encrypted_message
    key = Wallet.new

    priv_encrypted_message = key.private_key.private_encrypt( )

    assert_equal "pear", key.public_key.public_decrypt(priv_encrypted_message)
  end

  def test_private_key_decrypts_public_key_encrypted_message
    key = Wallet.new

    pub_encrypted_message = key.public_key.public_encrypt("pear")

    assert_equal "pear", key.private_key.private_decrypt(pub_encrypted_message)
  end

  def test_it_signs_strings_into_base_64
    key = Wallet.new

    assert_equal String, key.sign("pear").class
  end
end

# PEM-formatted: RSA public key of last transaction
#
# SHA256 hash of previous transaction (being spent)
#
# RSA signature of the SHA256 hash of the current transaction