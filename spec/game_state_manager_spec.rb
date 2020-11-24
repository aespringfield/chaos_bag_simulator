require 'spec_helper'
require 'game_state_manager'
require 'bag'
require 'game_state'
require 'token'

describe GameStateManager do
  it 'draws a token' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 },
        ]
    )

    initial_game_state = GameState.new(bag: bag)
    game_state = GameStateManager.draw_token(game_state: initial_game_state)
    expect(game_state.revealed_tokens.count).to eq 1
    expect(game_state.bag.tokens.count).to eq 3
    expect(initial_game_state.bag.tokens.count).to eq 4
    initial_game_state.bag.tokens.each do |token|
      expect(game_state.bag.tokens).not_to include token
    end
  end

  it 'removes a spooky token' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 },
        ]
    )

    initial_game_state = GameState.new(bag: bag)
    game_state = GameStateManager.remove_token(game_state: initial_game_state, type: :skull)
    expect(game_state.bag.tokens.count).to eq 3
    expect(game_state.bag.tokens.select { |token| token.type == :skull }.count).to eq 1
    expect(game_state.revealed_tokens.count).to eq 0
    expect(initial_game_state.bag.tokens.count).to eq 4
  end

  it 'removes a number token' do
    bag = Bag.new(
        tokens: [
          Token.new(type: :number, value: 1),
          Token.new(type: :number, value: -1),
          Token.new(type: :number, value: -1),
          Token.new(type: :cultist) { -2 },
          Token.new(type: :cultist) { -2 },
        ]
    )

    initial_game_state = GameState.new(bag: bag)
    game_state = GameStateManager.remove_token(game_state: initial_game_state, type: :number, value: -1)
    expect(game_state.bag.tokens.count).to eq 4
    expect(game_state.bag.tokens.select { |token| token.type == :number && token.value == -1 }.count).to eq 1
    expect(game_state.revealed_tokens.count).to eq 0
    expect(initial_game_state.bag.tokens.count).to eq 5
  end

  it 'adds a number token' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 },
        ]
    )

    initial_game_state = GameState.new(bag: bag)
    game_state = GameStateManager.add_token(game_state: initial_game_state, token: Token.new(type: :number, value: -1))
    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.bag.tokens.select { |token| token.type == :number && token.value == -1 }.count).to eq 1
    expect(game_state.revealed_tokens.count).to eq 0
    expect(initial_game_state.bag.tokens.count).to eq 4
  end

  it 'adds a spooky token' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 },
        ]
    )

    initial_game_state = GameState.new(bag: bag)
    game_state = GameStateManager.add_token(game_state: initial_game_state, token: Token.new(type: :skull))
    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.bag.tokens.select { |token| token.type == :skull }.count).to eq 3
    expect(game_state.revealed_tokens.count).to eq 0
    expect(initial_game_state.bag.tokens.count).to eq 4
  end

  it 'returns tokens to bag' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 },
        ]
    )

    revealed_tokens = [
        Token.new(type: :number, value: 0),
        Token.new(type: :number, value: -3)
    ]

    initial_game_state = GameState.new(
      bag: bag,
      revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.return_all_tokens_to_bag(game_state: initial_game_state)
    expect(game_state.bag.tokens.count).to eq 6
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :cultist, :number, :number]
    expect(game_state.revealed_tokens.count).to eq 0
    expect(initial_game_state.bag.tokens.count).to eq 4
    expect(initial_game_state.revealed_tokens.count).to eq 2
  end

  it 'returns tokens to bag when bless revealed' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :bless),
        ]
    )

    revealed_tokens = [
        Token.new(type: :bless),
        Token.new(type: :number, value: -3)
    ]

    initial_game_state = GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.return_all_tokens_to_bag(game_state: initial_game_state)
    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :bless, :number]
    expect(initial_game_state.bag.tokens.count).to eq 4
    expect(initial_game_state.revealed_tokens.count).to eq 2
  end

  it 'returns tokens to bag when curse revealed' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :curse),
        ]
    )

    revealed_tokens = [
        Token.new(type: :curse),
        Token.new(type: :number, value: -3)
    ]

    initial_game_state = GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.return_all_tokens_to_bag(game_state: initial_game_state)
    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :curse, :number]
    expect(initial_game_state.bag.tokens.count).to eq 4
    expect(initial_game_state.revealed_tokens.count).to eq 2
  end

  it 'ignores worst revealed token when it is a tentacles' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 },
        ]
    )

    revealed_tokens = [
        Token.new(type: :number, value: 0),
        Token.new(type: :number, value: -3),
        Token.new(type: :tentacles)
    ]

    initial_game_state = GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.ignore_worst_revealed_token(
        game_state: initial_game_state,
        elder_sign_value_resolver: lambda { |_| 0}
    )
    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.revealed_tokens.count).to eq 2
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :cultist, :tentacles]
    expect(game_state.revealed_tokens.map(&:type)).to eq [:number, :number]
    expect(initial_game_state.bag.tokens.count).to eq 4
    expect(initial_game_state.revealed_tokens.count).to eq 3
  end

  it 'ignores worst revealed token when it is a number' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 },
        ]
    )

    revealed_tokens = [
        Token.new(type: :number, value: 0),
        Token.new(type: :number, value: -3),
        Token.new(type: :elder_sign)
    ]

    initial_game_state = GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.ignore_worst_revealed_token(
        game_state: initial_game_state,
        elder_sign_value_resolver: lambda { |_| 1}
    )
    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.revealed_tokens.count).to eq 2
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :cultist, :number]
    expect(game_state.revealed_tokens.map(&:type)).to eq [:number, :elder_sign]
    expect(game_state.revealed_tokens.first.value).to eq 0
    expect(initial_game_state.bag.tokens.count).to eq 4
    expect(initial_game_state.revealed_tokens.count).to eq 3
  end

  it 'ignores worst revealed token when it is spooky' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 }
        ]
    )

    revealed_tokens = [
        Token.new(type: :number, value: 2),
        Token.new(type: :elder_sign),
        Token.new(type: :cultist) { 1 }
    ]

    initial_game_state = GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.ignore_worst_revealed_token(
        game_state: initial_game_state,
        elder_sign_value_resolver: lambda { |_| 3 }
    )
    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.revealed_tokens.count).to eq 2
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :cultist, :cultist]
    expect(game_state.revealed_tokens.map(&:type)).to eq [:number, :elder_sign]
    expect(game_state.revealed_tokens.first.value).to eq 2
    expect(initial_game_state.bag.tokens.count).to eq 4
    expect(initial_game_state.revealed_tokens.count).to eq 3
  end

  it 'ignores worst revealed token when it is a curse' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 }
        ]
    )

    revealed_tokens = [
        Token.new(type: :number, value: 2),
        Token.new(type: :elder_sign),
        Token.new(type: :curse)
    ]

    initial_game_state = GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.ignore_worst_revealed_token(
        game_state: initial_game_state,
        elder_sign_value_resolver: lambda { |_| 3 }
    )

    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.revealed_tokens.count).to eq 2
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :cultist, :curse]
    expect(game_state.revealed_tokens.map(&:type)).to eq [:number, :elder_sign]
    expect(game_state.revealed_tokens.first.value).to eq 2
  end

  it 'ignores worst revealed token when preferring spookies to numbers' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 }
        ]
    )

    revealed_tokens = [
        Token.new(type: :cultist) { -2 },
        Token.new(type: :number, value: -2),
        Token.new(type: :elder_sign)
    ]

    initial_game_state = GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.ignore_worst_revealed_token(
        game_state: initial_game_state,
        elder_sign_value_resolver: lambda { |_| 3 },
        opts: { prefer_spookies: true }
    )

    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.revealed_tokens.count).to eq 2
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :cultist, :number]
    expect(game_state.revealed_tokens.map(&:type)).to eq [:cultist, :elder_sign]
  end

  it 'ignores worst revealed token when preferring numbers to spookies' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull) { -1 },
            Token.new(type: :skull) { -1 },
            Token.new(type: :cultist) { -2 },
            Token.new(type: :cultist) { -2 }
        ]
    )

    revealed_tokens = [
        Token.new(type: :number, value: -2),
        Token.new(type: :elder_sign),
        Token.new(type: :cultist) { -2 }
    ]

    initial_game_state = GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )

    game_state = GameStateManager.ignore_worst_revealed_token(
        game_state: initial_game_state,
        elder_sign_value_resolver: lambda { |_| 3 },
        opts: { prefer_spookies: false }
    )

    expect(game_state.bag.tokens.count).to eq 5
    expect(game_state.revealed_tokens.count).to eq 2
    expect(game_state.bag.tokens.map(&:type)).to eq [:skull, :skull, :cultist, :cultist, :cultist]
    expect(game_state.revealed_tokens.map(&:type)).to eq [:number, :elder_sign]
  end
end