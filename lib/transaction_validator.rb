require 'pry'
require_relative 'wallet'
require_relative 'transaction'
require 'pry-nav'

class TransactionValidator
  attr_reader :full_txn, :archive, :wallet, :transaction

  def initialize(archive, transaction, wallet)
    @transaction = transaction
    @archive = archive
    @wallet = wallet
  end

  def extracted_signature
    transaction.signature(wallet)
  end

  def source_txn_outputs
    transaction.inputs.map do |source|
      lookup_source_in_archive(source)
    end
  end

  def lookup_source_in_archive(source)
    archive[source["source_hash"]][:outputs][source["source_index"]]
  end

  def valid_amount?
    current_transaction_total_value == source_txn_total_value
  end

  def source_txn_total_value
    source_txn_outputs.map do |output|
      output["amount"]
    end.inject(:+)
  end

  def current_transaction_total_value
    transaction.outputs.map do | output |
      output["amount"]
    end.inject(:+)
  end

  def valid_author?
    binary_signature = Base64.decode64(extracted_signature)

    pub_keys = source_txn_outputs.map { |output| output["address"] }

    pub_keys.map do |key|
      key_object = OpenSSL::PKey::RSA.new(key)
      key_object.public_decrypt(binary_signature) &&
      key_object.public_decrypt(binary_signature) == transaction.txn_wo_signature_sha
    end
  end

  def valid?
    valid_author? && valid_amount?
  end
end