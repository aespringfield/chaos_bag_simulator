require 'token'

class Bag
  attr_reader :tokens

  def self.build(
      number_values:,
      skull_count: 0,
      cultist_count: 0,
      tablet_count: 0,
      heart_count: 0,
      elder_sign_count: 1,
      tentacles_count: 1,
      bless_count: 0,
      curse_count: 0,
      spooky_rules:
  )
    tokens = []
      .concat(number_values.map { |value| Token.new(type: :number, value: value) })
      .concat(skull_count.times.map {
        Token.new(
            type: :skull,
            triggers_additional_token_pull: spooky_rules.skull_triggers_additional_token_pull
        ) { |args|
          spooky_rules.skull_rule.call(args)
        }
      })
      .concat(cultist_count.times.map {
        Token.new(
           type: :cultist,
           triggers_additional_token_pull: spooky_rules.cultist_triggers_additional_token_pull
        ) { |args| spooky_rules.cultist_rule.call(args) }
      })
      .concat(tablet_count.times.map {
         Token.new(
             type: :tablet,
             triggers_additional_token_pull: spooky_rules.tablet_triggers_additional_token_pull
         )  { |args| spooky_rules.tablet_rule.call(args) }
      })
      .concat(heart_count.times.map {
         Token.new(
             type: :heart,
             triggers_additional_token_pull: spooky_rules.heart_triggers_additional_token_pull
         )  { |game_state:| spooky_rules.heart_rule.call(game_state) }
      })
      .concat(elder_sign_count.times.map { Token.new(type: :elder_sign) })
      .concat(tentacles_count.times.map { Token.new(type: :tentacles) })
      .concat(bless_count.times.map { Token.new(type: :bless) })
      .concat(curse_count.times.map { Token.new(type: :curse) })

      Bag.new(tokens: tokens)
  end

  def initialize(tokens:)
    @tokens = tokens
  end

  def pull_token
    @tokens.sample
  end

  def add_token(token)
    @tokens << token
  end

  def deep_dup
    Bag.new(
      tokens: @tokens.map(&:dup)
    )
  end

  def remove_token(type:, value: nil)
    token_to_remove = @tokens.find do |token|
      token.type == type && (value.nil? || token.value == value)
    end
    @tokens.delete(token_to_remove)
  end

  class SpookyRules
    attr_reader :skull_rule, :cultist_rule, :tablet_rule, :heart_rule,
        :skull_triggers_additional_token_pull, :cultist_triggers_additional_token_pull,
        :tablet_triggers_additional_token_pull, :heart_triggers_additional_token_pull

    def initialize(
        skull_rule: nil,
        cultist_rule: nil,
        tablet_rule: nil,
        heart_rule: nil,
        skull_triggers_additional_token_pull: false,
        cultist_triggers_additional_token_pull: false,
        tablet_triggers_additional_token_pull: false,
        heart_triggers_additional_token_pull: false
    )
      @skull_rule = skull_rule
      @cultist_rule = cultist_rule
      @tablet_rule = tablet_rule
      @heart_rule = heart_rule
      @skull_triggers_additional_token_pull = skull_triggers_additional_token_pull,
      @cultist_triggers_additional_token_pull = cultist_triggers_additional_token_pull,
      @tablet_triggers_additional_token_pull = tablet_triggers_additional_token_pull,
      @heart_triggers_additional_token_pull = heart_triggers_additional_token_pull
    end
  end
end