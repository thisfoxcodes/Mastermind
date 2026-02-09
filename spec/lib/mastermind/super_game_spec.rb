# frozen_string_literal:true

module Mastermind
  RSpec.describe 'Game class using version :super' do
    before do
      @game = Mastermind::Game.new(:super)
    end

    it 'initializes game' do
      expect(@game.games_played).to eq(0)
      expect(@game.state).to eq(:new)
      expect(@game.turns_remaining).to eq(12)
      expect(@game.version).to eq(:super)
    end
  end

  RSpec.describe 'Start Super Game' do
    before do
      @game = Mastermind::Game.new(:super)
      @game.start
    end

    it 'when starting game, generates @code_maker with matching version' do
      expect(@game.instance_variable_get(:@code_maker).version).to eq(@game.version)
    end

    it 'can take a successful turn' do
      @game.guess(%w[W K G P C])

      expect(@game.turns_remaining).to eq(11)
    end

    it 'can check for invalid input when taking a turn' do
      input1 = %w[P P P P P P]
      input2 = %w[W C G W]

      expect { @game.guess(input1) }.to raise_error(CodeMaker::GuessError)
      expect { @game.guess(input2) }.to raise_error(CodeMaker::GuessError)
    end
  end
end
