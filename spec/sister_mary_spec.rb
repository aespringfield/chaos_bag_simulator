require 'spec_helper'
require 'investigators/sister_mary'
require 'bag'
require 'investigator'
require 'skill_test'
require 'game_state'

describe SisterMary do
  it 'has expected base stats' do
    sister_mary = SisterMary.new

    expect(sister_mary.base_willpower).to eq 4
    expect(sister_mary.base_intellect).to eq 2
    expect(sister_mary.base_combat).to eq 3
    expect(sister_mary.base_agility).to eq 3
  end

  it 'adds a bless token to bag when elder sign pulled and test successful' do
    sister_mary = SisterMary.new

    bag = Bag.new(
        tokens: [
            Token.new(type: :elder_sign)
        ]
    )

    skill_test = SkillTest.new(
        investigator: sister_mary,
        skill: :willpower,
        difficulty: 3
    )

    resolution = skill_test.perform(game_state: GameState.new(bag: bag))
    expect(resolution.result).to be :success
    expect(resolution.tokens.count).to eq 1
    expect(resolution.game_state.bag.tokens.count).to eq 1
    expect(resolution.game_state.bag.tokens.map(&:type)).to include :bless
  end

  it 'does not add a bless token to bag when elder sign pulled and test unsuccessful' do
    sister_mary = SisterMary.new

    bag = Bag.new(
        tokens: [
            Token.new(type: :elder_sign)
        ]
    )

    skill_test = SkillTest.new(
        investigator: sister_mary,
        skill: :willpower,
        difficulty: 8
    )

    resolution = skill_test.perform(game_state: GameState.new(bag: bag))
    expect(resolution.result).to be :failure
    expect(resolution.tokens.count).to eq 1
    expect(resolution.game_state.bag.tokens.map(&:type)).not_to include :bless
  end
end