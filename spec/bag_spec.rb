require 'spec_helper'
require 'bag'
require 'token'
require 'game_state'

describe Bag do
  let!(:bag) {
    Bag.new(
      tokens: [
          Token.new(type: :number, value: 1),
          Token.new(type: :number, value: 0),
          Token.new(type: :skull) { -1 },
          Token.new(type: :cultist) { -2 },
          Token.new(type: :tentacles),
          Token.new(type: :elder_sign) { 1 }
      ]
    )
  }

  it 'contains chaos tokens' do
    expect(bag.tokens.length).to be 6
  end

  it 'allows a token to be pulled' do
    expect(bag.pull_token).to be_kind_of(Token)
  end

  it 'allows a spooky token to be removed' do
    bag.remove_token(type: :cultist)

    expect(bag.tokens.length).to be 5
    expect(bag.tokens.map(&:type)).not_to include(:cultist)
  end

  it 'allows a number token to be removed' do
    bag.remove_token(type: :number, value: 0)

    expect(bag.tokens.length).to be 5
    expect(bag.tokens.select { |token| token.type == :number }.map(&:value) ).not_to include(0)
  end

  it 'allows a token to be added' do
    bag.add_token(Token.new(type: :bless))

    expect(bag.tokens.length).to be 7
    expect(bag.tokens.map(&:type)).to include(:bless)
  end

  it 'builds a bag' do
    bag = Bag.build(
       number_values: [1, 0, 0, -1, -1, -2, -2, -3, -9],
       skull_count: 3,
       heart_count: 2,
       spooky_rules: Bag::SpookyRules.new(
         skull_rule: lambda { |_| -1 },
         heart_rule: lambda { |game_state|
           game_state.scenario_specific_hash[:ghoul_count] > 1 ? -3 : 0
         },
         skull_triggers_additional_token_pull: true
       )
    )

    expect(bag.tokens.length).to be 16
    expect(bag.tokens.map(&:type)).to eq [:number, :number, :number, :number, :number, :number, :number, :number,
                                         :number, :skull, :skull, :skull, :heart, :heart, :elder_sign, :tentacles]

    skull_token = bag.tokens.find { |token| token.type == :skull }
    expect(skull_token.value_method.call(game_state: GameState.new(bag: bag))).to eq -1

    heart_token = bag.tokens.find { |token| token.type == :heart }
    game_state = GameState.new(bag: bag, scenario_specific_hash: { ghoul_count: 8 })
    expect(heart_token.value_method.call(game_state: game_state)).to eq -3
  end
end