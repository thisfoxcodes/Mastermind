# frozen_string_literal: true

module Mastermind
  RSpec.describe 'CodeMaker class using version :super' do
    before do
      @code_maker = Mastermind::CodeMaker.new(:super)
    end

    it 'creates a code on initialization' do
      expect(@code_maker.answer.class).to eq(Array)
      expect(@code_maker.answer.length).to eq(GameParams::LENGTH[@code_maker.version])
      @code_maker.answer.each do |code|
        expect(GameParams::VALID_OPTIONS[@code_maker.version]).to include(code)
      end
    end

    it 'version param matches :super' do
      expect(@code_maker.version).to eq(:super)
    end

    it 'each code on initialization is random' do
      @code_maker_dup = Mastermind::CodeMaker.new(:super)
      # Added while loop here to prevent 1/32768 chance of failing test
      @code_maker_dup = Mastermind::CodeMaker.new while @code_maker_dup.answer == @code_maker.answer
      expect(@code_maker.answer).to_not eq(@code_maker_dup.answer)
    end

    it 'can compare guesses, returning true if the guess matches' do
      answer = @code_maker.answer
      expect(@code_maker.compare_guess(answer)).to eq(true)
    end

    it 'can compare guesses, returning correct/misplaced counts if guess doesn\'t match' do
      answer = @code_maker.answer
      result = true
      # I force use of this loop at least once to ensure we get an `answer`
      # That doesn't match the @code_maker.answer
      # 1/32768 chance of this occurring.
      while result == true
        answer = []
        GameParams::LENGTH[@code_maker.version].times do
          answer << GameParams::VALID_OPTIONS[@code_maker.version].sample
        end
        result = @code_maker.compare_guess(answer)
      end
      expect(result.class).to eq(Hash)
      expect(result[:correct]).to be_a(Integer)
      expect(result[:misplaced]).to be_a(Integer)
      expect(result[:correct] + result[:misplaced]).to be <= 5
    end

    it 'can compare guesses without an instance of the class' do
      a = %w[R G B P C]
      b = %w[R G B K C]
      expect(Mastermind::CodeMaker.compare(a, b, :super)).to eq({ correct: 4, misplaced: 0 })
      expect(Mastermind::CodeMaker.compare(a, a.dup, :super)).to eq(true)
    end

    it 'compare_guess checks for input length' do
      a = %w[R G B W K]
      b = %w[R G B W]
      expect { Mastermind::CodeMaker.compare(a, b, :super) }.to raise_error(CodeMaker::GuessError)
    end
  end
end
