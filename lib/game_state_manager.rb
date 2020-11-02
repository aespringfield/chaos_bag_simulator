class GameStateManager
  def self.draw_token(game_state:)
    pulled_token = game_state.bag.pull_token
    GameState.new(
      bag: Bag.new(
        tokens: game_state.bag.tokens.reject { |token| token == pulled_token }.map(&:dup)
      ),
      revealed_tokens: game_state.revealed_tokens.map(&:dup) << pulled_token.dup
    )
  end

  def self.remove_token(game_state:, type:, value: nil)
    bag = game_state.bag.deep_dup
    bag.remove_token(type: type, value: value)
    GameState.new(
        bag: bag,
        revealed_tokens: game_state.revealed_tokens.map(&:dup)
    )
  end

  def self.add_token(game_state:, token:)
    bag = game_state.bag.deep_dup
    bag.add_token(token.dup)
    GameState.new(
      bag: bag,
      revealed_tokens: game_state.revealed_tokens.map(&:dup)
    )
  end

  def self.return_tokens_to_bag(game_state:, tokens: [])
    bag = game_state.bag.deep_dup
    tokens.each { |token| bag.add_token(token.dup) }
    revealed_tokens = game_state.revealed_tokens.reject { |revealed_token|
      tokens.map { |token|
        revealed_token == token
      }.include? true
    }.map(&:dup)

    GameState.new(
        bag: bag,
        revealed_tokens: revealed_tokens
    )
  end

  def self.return_all_tokens_to_bag(game_state:)
    return_tokens_to_bag(game_state: game_state, tokens: game_state.revealed_tokens)
  end

  def self.ignore_worst_revealed_token(game_state:, elder_sign_value_resolver:)
    if game_state.revealed_tokens.contains_autofail?
      return_tokens_to_bag(
          game_state: game_state,
          tokens: game_state.revealed_tokens.select { |token| token.type == :tentacles }
      )
    else
      token_to_remove = game_state.revealed_tokens.sort_by { |token|
        token.value(elder_sign_value_resolver: elder_sign_value_resolver, game_state: game_state)
      }.first
      return_tokens_to_bag(game_state: game_state, tokens: [token_to_remove])
    end
  end
end