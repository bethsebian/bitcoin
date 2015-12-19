require_relative '../lib/wallet'
require 'minitest/autorun'
require 'pry'

class WalletTest < Minitest::Test
  attr_reader :wallet

  def setup
    @wallet = Wallet.new
  end

  def test_it_initializes_with_a_private_key
    assert_equal 'OpenSSL::PKey::RSA', wallet.private_key.class.to_s
    assert wallet.private_key.public?
    assert wallet.private_key.private?
  end

  def test_it_initializes_with_a_public_key
    assert_equal 'OpenSSL::PKey::RSA', wallet.public_key.class.to_s
    refute wallet.public_key.private?
    assert wallet.public_key.public?
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
    expected = "NbK22TpmbaKYLIeGgqYsw2oXn1b4eTwne/95cBNdKnyCI38LH/ieHV6P8Gwj\nR+KLw1mXIoNlZ65tdF26l7U+i9PZ28YWjcbBDrS/xZzfk1ZhllMoTD4ApcWN\nrJeVxEBnLbY7siBs/ubWVsSfqj5Y+CF37yTKwp8T6mRh8/ThlZNw8GPsufgZ\nD8cD/q19hAkxyEPqd0XCrkMCtf09LLp6VrEM6cHAWB8hjojj+rNdWPMSlScP\nvinRzgCnsD9pc+n3L1lurKtZIfn+gXAbDfVXOqk49XnBmFL0yEo9RH46Up1r\nmX5xFNwAG6vkYI9KR4WYfyK4tW4BQ8Er95bCBobLJA==\n"
    assert_equal expected, wallet.sign_transaction("pear")
  end
end