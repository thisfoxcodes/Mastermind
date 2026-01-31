# frozen_string_literal: true

require_relative 'code_maker'

module Mastermind
  # Game manages the state and flow of a Mastermind game.
  # It coordinates between the player and the CodeMaker.
  class Game
    class GameError < StandardError; end

    include GameParams

    attr_reader :turns_remaining, :state, :version, :games_played

    def initialize(version = :regular)
      @code_maker = nil
      @games_played = 0
      @state = :new # Possible States: :new, :in_progress, :won, :lost
      @version = version
      @turns_remaining = TURNS[@version]
    end

    def start
      raise GameError, :invalid_version unless VERSIONS.include?(version)

      @code_maker = CodeMaker.new(@version)
      @state = :in_progress
      self
    end

    # Returns a hash with:
    #   - won: boolean
    #   - turns_remaining: integer
    #   - state: symbol (:in_progress, :won, :lost)
    #   - correct: integer (if didn't win)
    #   - misplaced: integer (if didn't win)
    #   - secret_code: array (if won)
    def guess(player_guess)
      result = @code_maker.compare_guess(player_guess)

      @turns_remaining -= 1

      if result == true
        @state = :won
        return {
          turns_remaining: @turns_remaining,
          state: @state,
          secret_code: @code_maker.answer
        }
      end

      @state = :lost if @turns_remaining.zero?

      {
        won: false,
        turns_remaining: @turns_remaining,
        state: @state,
        correct: result[:correct],
        misplaced: result[:misplaced]
      }
    end

    def secret_code
      return nil if @state == :in_progress || @state == :new

      @code_maker.answer
    end

    def in_progress?
      @state == :in_progress
    end

    def game_over?
      @state == :won || @state == :lost
    end

    def new_round
      @games_played += 1
      start
    end

    def code_length
      LENGTH[@version]
    end

    def valid_colors
      VALID_OPTIONS[@version]
    end

    def max_turns
      TURNS[@version]
    end
  end
end
