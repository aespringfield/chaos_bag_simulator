class Investigator
  attr_reader :base_willpower, :base_intellect, :base_combat, :base_agility, :elder_sign_value_resolver, :elder_sign_side_effects_resolver

  def initialize(base_stats:, elder_sign_value_resolver:, elder_sign_side_effects_resolver: nil)
    @base_willpower = base_stats[:willpower]
    @base_intellect = base_stats[:intellect]
    @base_combat = base_stats[:combat]
    @base_agility = base_stats[:agility]
    @elder_sign_value_resolver = elder_sign_value_resolver
    @elder_sign_side_effects_resolver = elder_sign_side_effects_resolver
  end

  # def trigger_elder_sign_ability(skill_test_outcome:)
  #   @elder_sign_ability.call(skill_test_outcome)
  # end

  def willpower
    @base_willpower
  end

  def intellect
    @base_intellect
  end

  def combat
    @base_combat
  end

  def agility
    @base_agility
  end
end