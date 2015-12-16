require 'openssl'
require_relative 'wallet'
require 'pry'
require 'json'

class Transaction
  attr_reader :inputs, :outputs

  def initialize(inputs, outputs)
    @inputs = inputs
    @outputs = outputs
  end

  def input_array
    inputs.map { |input| [input["source_hash"], input["source_index"]]}
  end

  def output_array
    outputs.map { |output| [output["amount"], output["address"]] }
  end

  def input_array_with_signature
    wallet = Wallet.new
    txn_signature = signature(wallet)
    inputs.map { |input| [input["source_hash"], input["source_index"], txn_signature ]}
  end

  def pre_sign_package
    txn_array = [input_array, output_array]
    txn_json = txn_array.to_json
    txn_SHA256_hash = Digest::SHA256.hexdigest('txn_json')
  end

  def signature(wallet)
    # for security, how can we best limit use of private_key?
    wallet.sign_transaction(pre_sign_package)
  end

  def bundle_full_txn
    txn_array = [input_array_with_signature, output_array]
    txn_json = txn_array.to_json
    txn_SHA256_hash = Digest::SHA256.hexdigest('txn_json')
  end
end
