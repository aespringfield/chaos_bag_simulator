class GameState
  # TODO: make bag a namespaced class here that inherits from array
  attr_reader :bag, :revealed_tokens, :resolved_tokens, :scenario_specific_hash

  def initialize(bag:, revealed_tokens: [], resolved_tokens: [], scenario_specific_hash: {})
    @bag = bag
    @revealed_tokens = RevealedTokens.new(revealed_tokens)
    @resolved_tokens = resolved_tokens
    @scenario_specific_hash = scenario_specific_hash
  end

  class RevealedTokens < Array
    def contains_autofail?
      map(&:type).include? :tentacles
    end
  end
end