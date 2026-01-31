# frozen_string_literal: true

module Mastermind
  RSpec.describe 'CodeMaker class using version :regular' do
    before do
      @code_maker = Mastermind::CodeMaker.new(:regular)
    end

    it 'creates a code on initialization' do
      expect(@code_maker.answer.class).to eq(Array)
      expect(@code_maker.answer.length).to eq(GameParams::LENGTH[@code_maker.version])
      @code_maker.answer.each do |code|
        expect(GameParams::VALID_OPTIONS[@code_maker.version]).to include(code)
      end
    end

    it 'version parameter is optional and defaults to :regular' do
      my_set = Mastermind::CodeMaker.new(:regular)

      expect(my_set.answer.length).to eq(4)
      expect(my_set.version).to eq(@code_maker.version)
      expect(@code_maker.answer.length).to eq(4)
      expect(@code_maker.version).to eq(:regular)
    end

    it 'defaults invalid version option to :regular' do
      my_set_wrong = Mastermind::CodeMaker.new(:test)
      expect(my_set_wrong.version).to eq(:regular)
    end

    it 'each code on initialization is random' do
      @code_maker_dup = Mastermind::CodeMaker.new
      # Added while loop here to prevent 1/1296 chance of failing test
      @code_maker_dup = Mastermind::CodeMaker.new while @code_maker_dup.answer == @code_maker.answer
      expect(@code_maker.answer).to_not eq(@code_maker_dup.answer)
    end

    it 'can compare guesses, returning won: true if the guess matches' do
      answer = @code_maker.answer
      expect(@code_maker.compare_guess(answer)).to eq(true)
    end

    it 'can compare guesses, returning correct/misplaced counts if guess doesn\'t match' do
      answer = @code_maker.answer
      result = true
      # Force a non-matching guess
      while result == true
        answer = []
        GameParams::LENGTH[@code_maker.version].times do
          answer << GameParams::VALID_OPTIONS[@code_maker.version].sample
        end
        result = @code_maker.compare_guess(answer)
      end
      expect(result).to be_a(Hash)
      expect(result[:correct]).to be_a(Integer)
      expect(result[:misplaced]).to be_a(Integer)
      expect(result[:correct] + result[:misplaced]).to be <= 4
    end

    it 'checks validity for input when taking a guess' do
      expect { @code_maker.compare_guess('test') }.to raise_error(CodeMaker::GuessError)
      expect { @code_maker.compare_guess(%w[G G G G G G]) }.to raise_error(CodeMaker::GuessError)
      expect { @code_maker.compare_guess(%w[GG GG GG GG]) }.to raise_error(CodeMaker::GuessError)
      expect { @code_maker.compare_guess(%w[1 1 1 1]) }.to raise_error(CodeMaker::GuessError)
      expect { @code_maker.compare_guess(%w[R P C C]) }.to raise_error(CodeMaker::GuessError)
    end

    it 'can compare guesses without an instance of the class' do
      a = %w[R G B W]
      b = %w[R G B K]
      invalid_result = Mastermind::CodeMaker.compare(a, b)
      expect(invalid_result).to eq({ correct: 3, misplaced: 0 })

      result = Mastermind::CodeMaker.compare(a, a.dup)
      expect(result).to eq(true)
    end

    it 'compare class method checks for input length' do
      a = %w[R G B W K]
      b = %w[R G B W]
      expect { CodeMaker.compare(a, b) }.to raise_error(CodeMaker::GuessError)
    end

    it 'allows setting a custom answer for testing' do
      @code_maker.set_answer(%w[R R R R])
      expect(@code_maker.answer).to eq(%w[R R R R])
    end
  end
end
