require('investigator')
require('token')

class SisterMary < Investigator
  def initialize
    super(
       base_stats: {
          willpower: 4,
          intellect: 2,
          combat: 3,
          agility: 3
      },
       elder_sign_value_resolver: Proc.new { 1 },
       elder_sign_side_effects_resolver: lambda do |resolution:|
         return resolution.game_state if resolution.result == :failure

         GameStateManager.add_token(game_state: resolution.game_state, token: Token.new(type: :bless))
       end
    )
  end
end