require 'game_state_manager'

class SkillTest
  def initialize(investigator:, skill:, difficulty:, opts: {})
    @investigator = investigator
    @skill = skill
    @difficulty = difficulty
    @skill_boost = 0
    @opts = opts
  end

  def boost_skill_value(by:)
    @skill_boost += by
  end

  def perform(game_state:, opts: { reveal_count: 1 }, &block)
    revealed_token_game_state = reveal_tokens(game_state: game_state, opts: perform_opts(opts: opts))
    resolve(game_state: (block ? block.call(game_state: revealed_token_game_state) : revealed_token_game_state))
  end

  def reveal_tokens(game_state:, opts: { reveal_count: 1 })
    return game_state if game_state.bag.tokens.count == 0

    game_state = GameStateManager.draw_token(game_state: game_state)
    new_token = game_state.revealed_tokens.last
    should_pull_again = should_pull_another_token(game_state: game_state, token: new_token, opts: opts)

    if should_pull_again
      reveal_tokens(game_state: game_state, opts: opts)
    else
      adjust_game_state_for_olive_mcbride(game_state: game_state)
    end
  end

  def resolve(game_state:)
    return Resolution.new(
        result: :failure,
        game_state: game_state
    ) if game_state.revealed_tokens.contains_autofail?

    differential = calculate_differential(game_state.revealed_tokens.map { |token|
      token.value(elder_sign_value_resolver: @investigator.elder_sign_value_resolver)
    }.sum)

    result = differential < 0 ? :failure : :success
    game_state = call_investigator_side_effects_resolver(
        resolution: Resolution.new(
            result: result,
            differential: differential,
            game_state: game_state
        )
    )
    return Resolution.new(result: result, differential: differential, game_state: game_state)
  end

  private

  def perform_opts(opts:)
    return @opts[:use_olive_mcbride] ? opts.merge(reveal_count: opts[:reveal_count] + 2) : opts
  end

  def adjust_game_state_for_olive_mcbride(game_state: game_state)
    if @opts[:use_olive_mcbride]
      GameStateManager.ignore_worst_revealed_token(
          game_state: game_state,
          elder_sign_value_resolver: @investigator.elder_sign_value_resolver
      )
    else
      game_state
    end
  end

  # def adjust_game_state_after_initial_resolution(resolution:)
  #   return
  # end

  def calculate_differential(tokens_sum)
    calculate_modified_skill(tokens_sum) - @difficulty + @skill_boost
  end

  def calculate_modified_skill(tokens_sum)
    initial_modified_skill = @investigator.send(@skill) + tokens_sum
    initial_modified_skill < 0 ? 0 : initial_modified_skill
  end

  def should_pull_another_token(game_state:, token:, opts: { reveal_count: 1 })
    token.triggers_additional_token_pull? || game_state.revealed_tokens.count < opts[:reveal_count]
  end

  def call_investigator_side_effects_resolver(resolution:)
    @investigator&.elder_sign_side_effects_resolver&.call(resolution: resolution) || resolution.game_state
  end

  class Resolution
    attr_reader :result, :differential, :game_state

    def initialize(result:, game_state:, differential: nil)
      @result = result
      @differential = differential
      @game_state = game_state
    end

    def tokens
      @game_state.revealed_tokens
    end
  end
end


