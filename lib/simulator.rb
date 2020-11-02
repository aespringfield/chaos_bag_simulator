require 'game_state'

class Simulator
  def initialize(skill_test:, bag:, times:, opts: {})
    @skill_test = skill_test
    @game_state = GameState.new(
        bag: bag
    )
    @times = times
    @opts = opts
    @failures = 0
    @successes = 0
  end

  def run(times_left: @times)
    if (@opts[:skill_test_boost])
      @skill_test.boost_skill_value(by: @opts[:skill_test_boost])
    end

    resolution = @skill_test.perform(game_state: @game_state)

    @failures = @failures + 1 if resolution.result == :failure
    @successes = @successes + 1 if resolution.result == :success

    remaining_runs = times_left - 1

    if times_left > 1
      run(times_left: remaining_runs)
    else
      puts "successes: #{(@successes.to_f / @times) * 100}%; failures: #{(@failures.to_f / @times) * 100}%"
    end
  end
end