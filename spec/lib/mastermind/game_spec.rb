# frozen_string_literal: true

require_relative '../../helper/spec_helper'

module Mastermind
  include GameParams

  RSpec.describe Game do
    before do
      # $stdout.stub(:write)
      @game = Mastermind::Game.new
    end

    it 'initializes game' do
      expect(@game.state).to eq(:new)
      expect(@game.turns_remaining).to eq(10)
      expect(@game.version).to eq(:regular)
      expect(@game.games_played).to eq(0)
    end

    it 'fails to start game due to test version' do
      invalid_game = Mastermind::Game.new(:test)

      # expect(invalid_game.version).to eq(:test)
      error = Mastermind::Game::GameError
      expect { invalid_game.start }.to raise_error(error) do |e|
        e.message == 'invalid_version'
      end
    end
  end

  # Tests After Game Begins
  RSpec.describe 'Start Game' do
    before do
      # $stdout.stub(:write)
      @game = Mastermind::Game.new
      @game.start
    end

    it 'starts a game' do
      expect(@game.state).to eq(:in_progress)
      expect(@game.instance_variable_get(:@code_maker).class).to eq(Mastermind::CodeMaker)
    end

    it 'generates @code_maker with matching version, when starting game' do
      expect(@game.instance_variable_get(:@code_maker).version).to eq(@game.version)
    end

    it 'can take a successful turn' do
      @game.guess(%w[W K G W])
      expect(@game.turns_remaining).to eq(9)
    end

    it 'can take a winning turn' do
      secret_code = @game.instance_variable_get(:@code_maker).answer
      expected_result = {
        turns_remaining: 9,
        state: :won,
        secret_code: secret_code
      }

      expect(expected_result).to eq(@game.guess(secret_code))
    end

    it 'can check for invalid input when taking a turn' do
      input1 = 'eeee'.upcase.chars
      input2 = 'kasdinfosbunaodimsf123r029jf!@#'.upcase.chars
      input3 = []
      input4 = 1

      expect { @game.guess(input1) }.to raise_error(CodeMaker::GuessError)
      expect { @game.guess(input2) }.to raise_error(CodeMaker::GuessError)
      expect { @game.guess(input3) }.to raise_error(CodeMaker::GuessError)
      expect { @game.guess(input4) }.to raise_error(CodeMaker::GuessError)
    end
  end
end
