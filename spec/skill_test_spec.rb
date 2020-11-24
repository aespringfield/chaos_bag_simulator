require 'spec_helper'
require 'skill_test'
require 'bag'
require 'investigator'
require 'token'
require 'game_state'
require 'game_state_manager'

describe SkillTest do
  let!(:bag) { Bag.new(
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

  let!(:investigator) {
      Investigator.new(
        base_stats: {
            willpower: 4,
            intellect: 2,
            combat: 3,
            agility: 3
        },
        elder_sign_value_resolver: Proc.new { 1 }
    )
  }

  let!(:skill_test) {
      SkillTest.new(
        investigator: investigator,
        skill: :willpower,
        difficulty: 4
    )
  }

  it 'reveals tokens' do
    game_state = GameState.new(
        bag: bag
    )
    tokens = skill_test.reveal_tokens(game_state: game_state).revealed_tokens

    expect(tokens.count).to eq 1
    expect(tokens.first).to be_kind_of Token
  end

  it 'reveals additional tokens but stops when bag is empty' do
    bag = Bag.new(
        tokens: [
            Token.new(type: :skull, triggers_additional_token_pull: true) { -1 },
            Token.new(type: :skull, triggers_additional_token_pull: true) { -1 },
            Token.new(type: :cultist, triggers_additional_token_pull: true) { -2 },
            Token.new(type: :cultist, triggers_additional_token_pull: true) { -2 },
        ]
    )

    skill_test = SkillTest.new(
        investigator: investigator,
        skill: :willpower,
        difficulty: 4
    )
    game_state = GameState.new(
        bag: bag
    )

    tokens = skill_test.reveal_tokens(game_state: game_state).revealed_tokens
    expect(tokens.length).to eq 4
  end

  it 'resolves a skill test when autofail' do
    token = Token.new(type: :tentacles)
    game_state = GameState.new(
      bag: bag,
      revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :failure
  end

  it 'resolves a skill test when number that should succeed by > 0' do
    token = Token.new(type: :number, value: 1)

    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :success
  end

  it 'resolves a skill test when number that should succeed by 0' do
    token = Token.new(type: :number, value: 0)

    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :success
  end

  it 'resolves a skill test when number that should fail' do
    token = Token.new(type: :number, value: -1)

    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :failure
  end

  it 'resolves a skill test when spooky that should succeed' do
    token = Token.new(type: :skull) { 0 }

    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :success
  end

  it 'resolves a skill test when spooky that should fail' do
    token = Token.new(type: :skull) { -1 }

    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :failure
  end

  it 'resolves a skill test when elder sign' do
    token = Token.new(type: :elder_sign) { 1 }

    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :success
  end

  it 'resolves a skill test when bless that should succeed' do
    token1 = Token.new(type: :bless)
    token2 = Token.new(type: :number, value: -1)

    game_state = GameState.new(
        bag: Bag.new(tokens: [token2]),
        revealed_tokens: [token1]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :success
    expect(resolution.differential).to eq 1
    expect(resolution.tokens).to eq [token1, token2]
  end

  it 'resolves a skill test when bless that should fail' do
    token1 = Token.new(type: :bless)
    token2 = Token.new(type: :number, value: -5)

    game_state = GameState.new(
        bag: Bag.new(tokens: [token2]),
        revealed_tokens: [token1]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :failure
    expect(resolution.differential).to eq -3
    expect(resolution.tokens).to eq [token1, token2]
  end

  it 'resolves a skill test when curse that should succeed' do
    token1 = Token.new(type: :curse)
    token2 = Token.new(type: :number, value: 3)

    game_state = GameState.new(
        bag: Bag.new(tokens: [token2]),
        revealed_tokens: [token1]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :success
    expect(resolution.differential).to eq 1
    expect(resolution.tokens).to eq [token1, token2]
  end

  it 'resolves a skill test when curse that should fail' do
    token1 = Token.new(type: :curse)
    token2 = Token.new(type: :number, value: 0)

    game_state = GameState.new(
        bag: Bag.new(tokens: [token2]),
        revealed_tokens: [token1]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :failure
    expect(resolution.differential).to eq -2
    expect(resolution.tokens).to eq [token1, token2]
  end

  it 'resolves a skill test when multiple tokens revealed' do
    token1 = Token.new(type: :number, value: -1)
    token2 = Token.new(type: :number, value: 0)
    token3 = Token.new(type: :number, value: -3)

    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token1, token2, token3]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :failure
    expect(resolution.differential).to be -4
  end

  it 'resolves a skill test when investigator skill less than difficulty but should succeed' do
    investigator = Investigator.new(
        base_stats: {
            willpower: 1,
            intellect: 2,
            combat: 3,
            agility: 3
        },
        elder_sign_value_resolver: Proc.new { 1 }
    )

    skill_test = SkillTest.new(
        investigator: investigator,
        skill: :willpower,
        difficulty: 4
    )

    token = Token.new(type: :number, value: 3)
    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :success
    expect(resolution.differential).to be 0
  end

  it 'resolves a skill test when token sum is positive but test should still fail' do
    investigator = Investigator.new(
        base_stats: {
            willpower: 2,
            intellect: 2,
            combat: 3,
            agility: 3
        },
        elder_sign_value_resolver: Proc.new { 1 }
    )

    skill_test = SkillTest.new(
        investigator: investigator,
        skill: :willpower,
        difficulty: 4
    )

    token = Token.new(type: :number, value: 1)
    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :failure
    expect(resolution.differential).to be -1
  end

  it 'resolves a skill test when modifier would have pushed skill value below zero' do
    investigator = Investigator.new(
        base_stats: {
            willpower: 1,
            intellect: 2,
            combat: 3,
            agility: 3
        },
        elder_sign_value_resolver: Proc.new { 1 }
    )

    skill_test = SkillTest.new(
        investigator: investigator,
        skill: :willpower,
        difficulty: 0
    )

    token = Token.new(type: :number, value: -4)
    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [token]
    )

    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to be :success
    expect(resolution.differential).to be 0
  end

  it 'performs skill test' do
    game_state = GameState.new(
        bag: bag
    )

    resolution = skill_test.perform(game_state: game_state)
    expect([:success, :failure]).to include(resolution.result)
    expect(resolution.tokens.count).to eq 1
  end

  it 'performs skill test with block' do
    token1 = Token.new(type: :number, value: -4)
    token2 = Token.new(type: :number, value: -4)
    token3 = Token.new(type: :number, value: -4)
    token4 = Token.new(type: :number, value: -1)
    token5 = Token.new(type: :number, value: 0)
    game_state = GameState.new(
        bag: Bag.new(tokens: [token1, token2, token3, token4, token5])
    )

    resolution = skill_test.perform(game_state: game_state, opts: { reveal_count: 3 }) do |game_state:|
      GameStateManager.ignore_worst_revealed_token(game_state: game_state, elder_sign_value_resolver: lambda { |_| 1 })
    end

    expect([:success, :failure]).to include(resolution.result)
    expect(resolution.tokens.count).to eq 2
  end

  it 'boosts skill value' do
    game_state = GameState.new(
        bag: bag,
        revealed_tokens: [Token.new(type: :number, value: -1)]
    )

    skill_test.boost_skill_value(by: 5)
    resolution = skill_test.resolve(game_state: game_state)
    expect(resolution.result).to eq :success
    expect(resolution.differential).to eq 4
  end

  it 'can use Olive McBride' do
    game_state = GameState.new(
        bag: bag,
    )

    skill_test = SkillTest.new(
        difficulty: 4,
        investigator: investigator,
        skill: :willpower,
        opts: {
            use_olive_mcbride: true
        }
    )

    resolution = skill_test.perform(game_state: game_state)
    expect(resolution.tokens.count).to eq 2
  end
end