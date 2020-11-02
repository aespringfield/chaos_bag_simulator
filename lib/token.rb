class Token
  attr_reader :type, :value_method

  def initialize(type:, value: nil, triggers_additional_token_pull: false, &value_method)
    raise "Invalid type" unless possible_types.include? type
    raise "Number token requires value" if type == :number && !value
    @type = type
    @fixed_value = value
    @triggers_additional_token_pull = triggers_additional_token_pull
    @value_method = value_method&.to_proc
  end

  def is_spooky?
    [:skull, :cultist, :tablet, :heart].include? @type
  end

  def triggers_additional_token_pull?
    @triggers_additional_token_pull
  end

  def value(elder_sign_value_resolver: nil, game_state: nil)
    raise "Tentacles token does not have a value" if @type == :tentacles

    @fixed_value || @value_method&.call(game_state: game_state) || elder_sign_value_resolver&.call(game_state: game_state)
  end

  private

  def possible_types
    [:number, :skull, :cultist, :tablet, :heart, :tentacles, :elder_sign, :bless, :curse]
  end
end