require 'spec_helper'
require 'simulator'
require 'bag'
require 'skill_test'
require 'investigators/sister_mary'

describe Simulator do
  it 'simulates' do
    skull_rule = lambda do |args|
      # if (args[:game_state]&.scenario_specific_hash[:flood_level] == :full)
      #   -3
      # else if (args[:game_state]&.scenario_specific_hash[:flood_level] == :partial)
      #        -2
      #      else
      #        -1
      #      end
      # end
      -1
    end

    cultist_rule = lambda { |_| -2 }
    tablet_rule = lambda { |_| -2 }
    heart_rule = lambda { |_| -3 }

    bag = Bag.build(
        number_values: [1, 0, 0, -1, -1, -1, -2, -2, -3, -4],
        skull_count: 2,
        cultist_count: 2,
        tablet_count: 2,
        heart_count: 2,
        spooky_rules: Bag::SpookyRules.new(
            skull_rule: skull_rule,
            cultist_rule: cultist_rule,
            tablet_rule: tablet_rule,
            heart_rule: heart_rule
        )
    )

    skill_test = SkillTest.new(investigator: SisterMary.new, skill: :willpower, difficulty: 5, opts: { use_olive_mcbride: false })


    simulator = Simulator.new(
      skill_test: skill_test,
      bag: bag,
      times: 5000
    )

    simulator.run
  end
end