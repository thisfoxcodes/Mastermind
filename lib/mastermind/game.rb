# frozen_string_literal: true

require_relative 'mastermind_owner'
require_relative '../../helper/color_print_helper'

# handles game initialization + processes for playing game
module Mastermind
  # The Game class. This handles game mechanics
  class MastermindGame
    include ColorHelper
    include GameParams

    attr_reader :game_counter,
                :code_maker,
                :version
    attr_accessor :turns_remaining,
                  :state

    def initialize(version = :regular)
      @turns_remaining = nil
      @code_maker = nil
      @state = nil
      @game_counter = 0
      @version = version_grab(version)
    end

    def start_game
      @turns_remaining ||= TURNS[version]
      @state = :in_progress
      @code_maker = Mastermind::Owner.new(version)
    end

    def g_turns
      @turns_remaining.to_s.red
    end

    def take_turn(player_guess)
      if validate(player_guess)
        @turns_remaining -= 1
        ans = @code_maker.compare_guess(player_guess)
        ans == true ? won : [ans[0], ans[1]]
      else
        false # invalid input, cannot take a turn
      end
    end

    def won
      4.times { print "⬤ ".green }
      puts ''
      print "Congrats! You have cracked the code ".green
      print @code_maker.answer.join.yellow
      print " with ".green
      print @turns_remaining.to_s.yellow
      puts ' turns left!'.green
      @state = :winner
    end

    def lost
      puts 'GAME OVER!'.red
      puts 'You have ran out of turns!'.red
      print "The Mastermind's code was: ".red
      puts @code_maker.answer.join.yellow
      @state = :loser
    end

    def add_game
      @game_counter += 1
    end

    private

    def version_grab(version)
      VERSIONS.include?(version) ? version : :regular
    end

    def validate(guess)
      result = true
      result &= guess.instance_of?(Array)
      result &= guess.length == LENGTH[version]
      guess.each do |i|
        result &= (VALID_OPTIONS[version]).include?(i)
      end

      result
    end
  end
end
