require 'pry'
require_relative 'wallet'
require_relative 'transaction'
require 'pry-nav'

class TransactionValidator
  attr_reader :full_txn, :archive, :current_pre_sign_package, :wallet_2

  def initialize(full_txn_json, archive, transaction_object, wallet_2)
    @full_txn = JSON.parse(full_txn_json)
    @archive = archive
    @current_pre_sign_package = transaction_object.pre_sign_package
    @wallet_2 = wallet_2
  end

  def extracted_signature
    full_txn[0][0][2]
  end

  def find_source_reference_info
    inputs = full_txn[0]

    inputs.map do |input|
      { "source_hash" => input[0], "source_index" => input[1] }
    end
  end

  def find_source_txn_output
    source_txns_lookup_info = find_source_reference_info

    source_txns = source_txns_lookup_info.map do |source|
      JSON.parse(archive[source_txns_lookup_info[0]["source_hash"]])[1][source_txns_lookup_info[0]["source_index"]]
    end
  end

  def source_txn_total_value
    find_source_txn_output.map do |amount, pub_key|
      amount
    end.inject(:+)
  end

  def current_transaction_total_value
    full_txn[1].map do | amount, pub_key |
      amount
    end.inject(:+)
  end

  def valid_amount?
    case current_transaction_total_value <=> source_txn_total_value
      when -1
        false # "You have inadequate funds"
      when 0
        true # "Transaction successful"
      when 1
        false # "You need to generate a txn output to yourself for difference of source_txn_total_value MINUS current_transaction_total_value"
        # eventually add code (in Transaction) to add additional output
    end
  end

  def valid_author?
    signature = Base64.decode64(extracted_signature)

    pub_keys_of_source_txns = find_source_txn_output.map do |amount, pub_key| #["-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA74d+zjjXvCMF0TTHQAJz\nm3Lgkca4gK3E3XNb+iCipPT7bPOqvl98waBAWOiip+e+h061rC9foJKuhotWe4Gu\na0upgIfB5We1H/eEGaEK2ZrfTdQa87JW6ejVkHP2B/lL2ibTmnT/CvJg2seY1YB0\nr+rBI3ONuvFVzVBNesASXNLrNE+dH0+zrUufDvo2a5y0mt0f4q8QFZDxX2ettE7I\nzpNt9ea5kRh/gpIeSeaU4uEUt3is/R2yr1JPzQN7Hx3efDfXJ7b6MnL6wU+/0D1R\nmE5YtARxnvXBZb3sALmg5fdyOVg/L/s2lizHKRk2ASaWCXu/X2Nw9ISuMhWgGMzs\ntwIDAQAB\n-----END PUBLIC KEY-----\n"]
      pub_key
    end

    pub_keys_of_source_txns.map do |key|
      key_object = OpenSSL::PKey::RSA.new(key)
      if key_object.public_decrypt(signature) && key_object.public_decrypt(signature) == current_pre_sign_package
      end
    end
  end

  def valid?
    valid_author? && valid_amount?
  end
end