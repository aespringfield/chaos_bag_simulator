require 'spec_helper'
require 'investigator'

describe Investigator do
  let!(:base_stats) {
    {
      willpower: 4,
      intellect: 2,
      combat: 3,
      agility: 3
    }
  }

  it 'has an elder sign value resolver' do
    investigator = Investigator.new(base_stats: base_stats, elder_sign_value_resolver: Proc.new{ 1 })

    expect(investigator.elder_sign_value_resolver.call).to eq 1
  end

  it 'has base skill values' do
    investigator = Investigator.new(
      base_stats: base_stats,
      elder_sign_value_resolver: Proc.new{ 1 }
    )

    expect(investigator.base_willpower).to eq 4
    expect(investigator.base_intellect).to eq 2
    expect(investigator.base_combat).to eq 3
    expect(investigator.base_agility).to eq 3
  end
end