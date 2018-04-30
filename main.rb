require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/contrib/all'
require 'jose_cryptodemo'
require 'json'

configure {
  set :server, :puma
}

class CryptodemoApi < Sinatra::Base
  configure do
    register Sinatra::Reloader
    register Sinatra::RespondWith
    BLOCKCHAIN = JoseCryptodemo::Blockchain.new()
  end
  
  get '/hello' do
    "Hello guys!!!"
  end
  
  post '/transactions/new', :provides => [:json] do
    @json = JSON.parse(request.body.read)
    
    index = BLOCKCHAIN.new_transaction(@json['sender'], @json['recipient'], @json['amount'])
    
    resp = {
      :message => "Transaction will be added to block: #{index}"
    }
    
    resp.to_json
  end
  
  get '/mine', :provides => [:json] do
    last_block = BLOCKCHAIN.last_block
    last_proof = last_block[:proof]
    
    proof = BLOCKCHAIN.proof_of_work(last_proof)
    
    previous_hash = BLOCKCHAIN.hash(last_block)
    block = BLOCKCHAIN.new_block(proof, previous_hash)
    
    resp = {
      :message => 'New block forged',
      :index => block[:index],
      :transactions => block[:transactions],
      :proof => block[:proof],
      :previous_hash => block[:previous_hash]
    }
    
    [200, resp.to_json]
  end
  
  get '/chain', :provides => [:json] do
    resp = {
      :chain => BLOCKCHAIN.chain,
      :length => BLOCKCHAIN.chain.length
    }
    
    resp.to_json
  end
  
end