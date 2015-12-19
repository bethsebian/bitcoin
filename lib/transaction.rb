require 'openssl'
require_relative 'wallet'
require 'pry'
require 'json'

class Transaction
  attr_reader :inputs, :outputs, :signature

  def initialize(inputs, outputs)
    @inputs = inputs
    @outputs = outputs
  end

  def input_array_with_signature(wallet)
    txn_signature = signature(wallet)
    inputs.map do |input|
      {
        "source_hash": input["source_hash"],
        "source_index": input["source_index"],
        "signature": txn_signature
      }
    end
  end

  def txn_wo_signature_sha
    ins = inputs.map { |input| [input["source_hash"], input["source_index"].to_s] }.join
    outs = outputs.map { |output| [output["amount"].to_s, output["address"]] }.join
    txn = ins + outs
    txn_wo_signature_SHA256 = Digest::SHA256.hexdigest(txn)
  end

  def signature(wallet)
    wallet.sign_transaction(txn_wo_signature_sha)
  end

  def complete_txn_string(wallet)
    ins = inputs.map { |input| [input["source_hash"], input["source_index"].to_s, signature(wallet) ] }.join
    outs= outputs.map { |output| [output["amount"].to_s, output["address"]] }.join
    txn = ins + outs
  end

  def txn_hash(wallet)
    Digest::SHA256.hexdigest(complete_txn_string(wallet))
  end

  def final_bundle(wallet, time = Time.now)
    {
      "inputs": input_array_with_signature(wallet),
      "outputs": outputs,
      "timestamp": time,
      "txn_hash": txn_hash(wallet)
    }
  end
end
