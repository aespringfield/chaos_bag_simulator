require 'spec_helper'
require 'token'

describe Token do
  it 'instantiates a numerical token' do
    token = Token.new(type: :number, value: -2)

    expect(token.type).to eq :number
    expect(token.is_spooky?).to be false
    expect(token.value).to eq -2
    expect(token.triggers_additional_token_pull?).to be false
  end

  it 'instantiates a spooky token' do
    token = Token.new(type: :skull) do | _ |
      -3
    end

    expect(token.type).to eq :skull
    expect(token.is_spooky?).to be true
    expect(token.value).to eq -3
    expect(token.triggers_additional_token_pull?).to be false
  end

  it 'instantiates a tentacles token' do
    token = Token.new(type: :tentacles)

    expect(token.type).to eq :tentacles
    expect(token.is_spooky?).to be false
    expect { token.value }.to raise_error("Tentacles token does not have a value")
    expect(token.triggers_additional_token_pull?).to be false
  end

  it 'instantiates an elder sign token' do
    token = Token.new(type: :elder_sign) { 1 }

    expect(token.type).to eq :elder_sign
    expect(token.is_spooky?).to be false
    expect(token.value).to eq 1
    expect(token.triggers_additional_token_pull?).to be false
  end

  it 'instantiates a token that modifies and triggers another token pull' do
    token = Token.new(type: :cultist, triggers_additional_token_pull: true) { -2 }

    expect(token.value).to eq -2
    expect(token.triggers_additional_token_pull?).to be true
  end
end