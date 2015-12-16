require_relative '../lib/wallet'
require 'minitest/autorun'
require 'minitest/pride'
require 'pry'

class WalletTest < Minitest::Test
  attr_reader :wallet

  def setup
    @wallet = Wallet.new
  end

  def test_it_creates_a_private_key
    wallet = Wallet.new.gen(2048)

    assert_equal 'OpenSSL::PKey::RSA', wallet.class.to_s
  end

  def test_it_initializes_with_a_private_key
    assert_equal 'OpenSSL::PKey::RSA', wallet.private_key.class.to_s
  end

  def test_it_initializes_with_a_public_key
    assert_equal 'OpenSSL::PKey::RSA', wallet.public_key.class.to_s
  end

  def test_private_key_encrypts_message
    priv_encrypted_message = wallet.private_key.private_encrypt("pear")

    assert_equal String, priv_encrypted_message.class
  end

  def test_public_key_decrypts_private_key_encrypted_message
    priv_encrypted_message = wallet.private_key.private_encrypt("pear")

    assert_equal "pear", wallet.public_key.public_decrypt(priv_encrypted_message)
  end

  def test_private_key_decrypts_public_key_encrypted_message
    pub_encrypted_message = wallet.public_key.public_encrypt("pear")

    assert_equal "pear", wallet.private_key.private_decrypt(pub_encrypted_message)
  end

  def test_it_signs_strings_into_base_64
    assert_equal String, wallet.sign_transaction("pear").class
  end
end