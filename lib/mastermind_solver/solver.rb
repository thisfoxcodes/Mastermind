# frozen_string_literal: true

require_relative '../mastermind/code_maker'
require_relative '../../helper/mastermind_solver/solver_first_guess_helper'
require_relative '../../helper/string_color_helper'
require_relative '../../helper/color_print_helper'
require_relative '../../helper/game_settings_helper'

require 'benchmark'

module MastermindSolver
  # Class that solves (and benchmarks) for Mastermind::CodeMaker.answer
  #
  # This class still contains some I/O for backwards compatibility.
  # For pure logic, use solve_silent which returns data without printing.
  class Solver
    include ColorHelper
    include GameParams

    attr_reader :correct_answer,
                :turns_to_solve,
                :code_maker,
                :solutions_set,
                :state,
                :version

    def initialize(version = :regular)
      @correct_answer = nil
      @turns_to_solve = 0
      @state = :unsolved
      @code_maker = Mastermind::CodeMaker.new(version)
      @version = @code_maker.version
      @solutions_set = fill_set
      @answer_set = solutions_set.dup
      @choice = version == :regular ? FIRST_GUESS_REGULAR : FIRST_GUESS_SUPER
    end

    # Backwards compatibility alias
    def owner
      @code_maker
    end

    # Solves for master code (CodeMaker.answer) - prints output
    def solve(var = Hash.new(0))
      result = solve_silent(var)
      return false unless result

      print "Found answer: #{color_print(@correct_answer)}, and it took ".cyan
      print "#{@turns_to_solve} ".red
      puts  'turns to solve.'.cyan
      [@correct_answer, @turns_to_solve]
    end

    # Solves without any I/O - returns result hash or false
    def solve_silent(var = Hash.new(0))
      if @state == :solved
        return false
      end

      guess = @version == :regular ? %w[R R G B] : %w[R R G G B]
      a = 1
      loop do
        result = @code_maker.compare_guess(guess)
        @turns_to_solve += 1

        if result[:won]
          @correct_answer = guess
          break
        end

        # Convert hash result to array format for internal use
        response = [result[:correct], result[:misplaced]]

        # Remove from S any code that would not give the same response if it were the code.
        prune_set(@solutions_set, guess, response)

        # Call @choice if a == 1 (our second guess). Otherwise, call minimax
        guess = a == 1 ? @choice[response] : minimax
        var[[response, guess]] += 1 if a == 1
        a += 1
      end
      @state = :solved
      { answer: @correct_answer, turns: @turns_to_solve }
    end

    # For restarting solver to default status, without calling fill_set again.
    def restart
      @solutions_set = @answer_set.dup
      @code_maker = Mastermind::CodeMaker.new(@version)
      @correct_answer = nil
      @turns_to_solve = 0
      @state = :unsolved
    end

    # For obtaining results of benchmarking solving + restart functions.
    def benchmark(number_of_tests, var = Hash.new(0))
      if number_of_tests.class != Integer || number_of_tests <= 0
        return { error: 'Method only accepts positive numbers' }
      end
      time = []
      number_of_tests.times do
        time << [Benchmark.realtime do
                   restart
                   solve_silent(var)
                 end, turns_to_solve]
      end
      restart
      calculate_and_return(time, number_of_tests)
    end

    # Benchmark with printed output (backwards compatibility)
    def benchmark_print(number_of_tests, var = Hash.new(0))
      result = benchmark(number_of_tests, var)
      return false if result[:error]

      print 'Entered # of Attempts: '.yellow
      print number_of_tests.to_s.red
      print ' | Total Realtime: '.yellow
      print result[:total_time].to_s.blue
      print ' | Avg Time: '.yellow
      print result[:avg_time].to_s.green
      print ' | Avg Number of Turns Taken: '.yellow
      print result[:avg_turns].to_s.green
      print ' | Max Turns Taken: '.yellow
      puts  result[:max_turns].to_s.blue
      result
    end

    private

    def calculate_and_return(my_info, number_of_tests)
      answer = [0, 0, 0] # [total_time, turns, max_turn]
      my_info.each do |x|
        answer[0] += x[0]
        answer[1] += x[1]
        answer[2] = [answer[2], x[1]].max
      end
      {
        total_time: answer[0],
        avg_time: answer[0].to_f / my_info.length,
        avg_turns: answer[1].to_f / my_info.length,
        max_turns: answer[2],
        num_tests: number_of_tests
      }
    end

    # Fill set with all possible code combinations.
    def fill_set
      s = Set.new
      if @code_maker.version == :regular # 1296 possible combinations for Mastermind.
        VALID_OPTIONS[@code_maker.version].each do |i|
          VALID_OPTIONS[@code_maker.version].each do |j|
            VALID_OPTIONS[@code_maker.version].each do |k|
              VALID_OPTIONS[@code_maker.version].each do |l|
                s.add([i, j, k, l])
              end
            end
          end
        end
      else # 32768 possible combinations for Super Mastermind.
        VALID_OPTIONS[@code_maker.version].each do |a|
          VALID_OPTIONS[@code_maker.version].each do |b|
            VALID_OPTIONS[@code_maker.version].each do |c|
              VALID_OPTIONS[@code_maker.version].each do |d|
                VALID_OPTIONS[@code_maker.version].each do |e|
                  s.add([a, b, c, d, e])
                end
              end
            end
          end
        end
      end
      s
    end

    # Removes guess from @solutions_set if any remaining guesses do not return exact same result.
    def prune_set(set, guess, response)
      set.delete(guess)
      set.each do |guess_set|
        result = Mastermind::CodeMaker.compare(guess, guess_set)
        set.delete(guess_set) unless [result[:correct], result[:misplaced]] == response
      end
    end

    # Finds the Maximum number of possible correct `guesses`
    # Then, it chooses the `guess` that is best to take next.
    def minimax
      next_guesses = [] # This is what will be returned. An array of guesses to take.
      score = {} # This will hold a map of guesses => max_score
      map = Hash.new(0) # This will hold a map of score_sets (eg. [1,0]) => number seen.
      min = max = 0
      @solutions_set.each do |full_answer|
        @solutions_set.each do |possible_answer|
          result = Mastermind::CodeMaker.compare(full_answer, possible_answer)
          correct_possible = [result[:correct], result[:misplaced]]
          map[correct_possible] += 1
        end
        max = map.values.max
        score[full_answer] = max
        map.clear
      end
      min = score.values.max
      score.each do |key, value|
        next_guesses << key if value == min
      end
      get_next_guess(next_guesses) # Return best guess from list. Prioritizes lowest
    end

    # Returns the first guess that exists.
    def get_next_guess(guesses)
      guesses.each do |g|
        return g if @solutions_set.include?(g)
      end
    end
  end
end
