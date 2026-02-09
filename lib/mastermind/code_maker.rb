# frozen_string_literal: true

require_relative '../../helper/game_settings_helper'

module Mastermind
  # CodeMaker is responsible for generating and holding the secret code.
  class CodeMaker
    class GuessError < StandardError; end

    include GameParams

    attr_reader :answer, :version

    def initialize(version = :regular)
      @version = VERSIONS.include?(version) ? version : :regular
      @answer = []
      create_code
    end

    # Set a specific answer (useful for testing)
    def set_answer(answer)
      @answer = answer
    end

    def compare_guess(guess)
      raise GuessError unless self.class.valid_guess?(guess, version)

      return true if guess == answer

      result = calculate_result(guess)
      { correct: result[0], misplaced: result[1] }
    end

    def self.valid_guess?(guess, version)
      return false unless guess.is_a?(Array)

      return false unless guess.length == LENGTH[version]

      guess.each do |char|
        return false unless VALID_OPTIONS[version].include?(char)
      end

      true
    end

    # Useful for solver algorithms
    def self.compare(answer, guess, version = :regular)
      raise GuessError unless valid_guess?(answer, version)
      raise GuessError unless valid_guess?(guess, version)

      return true if guess == answer

      answer_hash = Hash.new(0)
      answer.each { |c| answer_hash[c] += 1 }

      correct = 0
      misplaced_candidates = []

      guess.each_with_index do |c, i|
        if c == answer[i]
          correct += 1
          answer_hash[c] -= 1
        else
          misplaced_candidates << i
        end
      end

      misplaced = 0
      misplaced_candidates.each do |i|
        if answer_hash[guess[i]].positive?
          misplaced += 1
          answer_hash[guess[i]] -= 1
        end
      end

      { correct: correct, misplaced: misplaced }
    end

    private

    def calculate_result(guess)
      answer_hash = Hash.new(0)
      answer.each { |c| answer_hash[c] += 1 }

      correct = 0
      misplaced_candidates = []

      guess.each_with_index do |c, i|
        if c == answer[i]
          correct += 1
          answer_hash[c] -= 1
        else
          misplaced_candidates << i
        end
      end

      misplaced = 0
      misplaced_candidates.each do |i|
        if answer_hash[guess[i]].positive?
          misplaced += 1
          answer_hash[guess[i]] -= 1
        end
      end

      [correct, misplaced]
    end

    def create_code
      LENGTH[version].times do
        @answer << VALID_OPTIONS[version].sample
      end
    end
  end
end
