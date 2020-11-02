require 'spec_helper'
require 'game_state'
require 'bag'
require 'token'

describe GameState do
  it 'has a bag' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :number, value: 1),
            Token.new(type: :number, value: 0),
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :tentacles),
            Token.new(type: :elder_sign) { 1 }
        ]
    )

    game_state = GameState.new(bag: bag)
    expect(game_state.bag).to be_kind_of Bag
    expect(game_state.bag.tokens.count).to be 6
  end

  it 'has revealed tokens' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :number, value: 1),
            Token.new(type: :number, value: 0),
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :tentacles),
            Token.new(type: :elder_sign) { 1 }
        ]
    )

    revealed_tokens = [
        Token.new(type: :skull) { -1 },
        Token.new(type: :number, value: -2)
    ]

    game_state = GameState.new(bag: bag, revealed_tokens: revealed_tokens)
    expect(game_state.revealed_tokens.count).to eq 2
    expect(game_state.revealed_tokens[0]).to be revealed_tokens[0]
    expect(game_state.revealed_tokens[1]).to be revealed_tokens[1]
  end
end