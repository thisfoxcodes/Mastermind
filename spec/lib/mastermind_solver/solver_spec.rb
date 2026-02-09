# frozen_string_literal: true

require_relative '../../../lib/mastermind_solver/solver'

module MastermindSolver

  describe Solver do
    include ColorHelper
    
    before do
      @my_solver = MastermindSolver::Solver.new
      $stdout.stub(:write)
    end

    it 'creates solver and initializes with default values' do
      expect(@my_solver.correct_answer).to eq(nil)
      expect(@my_solver.turns_to_solve).to eq(0)
      expect(@my_solver.owner).to_not eq(nil)
      expect(@my_solver.state).to eq(:unsolved)
    end

    it 'verifies fill_set method creates set with 1296 different entries' do
      expect(@my_solver.solutions_set.length).to eq(1296)
      expect(@my_solver.solutions_set.include?(%w[
                                                 R R R R
                                               ])).to eq(true)
      expect(@my_solver.solutions_set.include?(%w[
                                                 R R G B
                                               ])).to eq(true)
    end

    it 'restart method generates new values for initialized variables WITHOUT .solve' do
      original_correct_answer = @my_solver.correct_answer
      original_turns_to_solve = @my_solver.turns_to_solve
      original_owner          = @my_solver.owner
      original_solutions_set  = @my_solver.solutions_set
      original_state          = @my_solver.state
      @my_solver.restart

      expect(@my_solver.correct_answer).to eq(original_correct_answer)
      expect(@my_solver.turns_to_solve).to eq(original_turns_to_solve)
      expect(@my_solver.owner).to_not eq(original_owner)
      expect(@my_solver.solutions_set).to eq(original_solutions_set)
      expect(@my_solver.state).to eq(original_state)
    end

    it 'return type for restart method is `:unsolved`' do
      return_type = @my_solver.restart

      expect(return_type).to eq(:unsolved)
    end

    it 'restart method generates new values for initialized variables AFTER .solve' do
      @my_solver.solve
      original_correct_answer = @my_solver.correct_answer
      original_turns_to_solve = @my_solver.turns_to_solve
      original_owner          = @my_solver.owner
      original_solutions_set  = @my_solver.solutions_set
      original_state          = @my_solver.state
      @my_solver.restart

      expect(@my_solver.correct_answer).to_not eq(original_correct_answer)
      expect(@my_solver.turns_to_solve).to_not eq(original_turns_to_solve)
      expect(@my_solver.owner).to_not eq(original_owner)
      expect(@my_solver.solutions_set).to_not eq(original_solutions_set)
      expect(@my_solver.state).to_not eq(original_state)
    end

    it 'can solve for owner code' do
      to_solve_for = @my_solver.owner.answer
      @my_solver.solve

      expect(@my_solver.correct_answer).to eq(to_solve_for)
      expect(@my_solver.state).to eq(:solved)
    end

    it 'solve method returns pair containing: @correct_answer, @turns_to_solve' do
      my_pair = @my_solver.solve

      expect(my_pair.class).to eq(Array)
      expect(my_pair.length).to eq(2)
      expect(my_pair[0]).to eq(@my_solver.correct_answer)
      expect(my_pair[1]).to eq(@my_solver.turns_to_solve)
    end

    it 'trying to solve already solved `solver` class results in `false` return type' do
      @my_solver.solve

      return_type = @my_solver.solve
      expect(return_type).to eq(false)
    end

    it 'when solving, makes the solution_set smaller by calling prune_set' do
      original_length = @my_solver.solutions_set.length
      @my_solver.solve

      expect(original_length).to be > @my_solver.solutions_set.length
    end

    it 'can benchmark solving for the master code' do
      expect(@my_solver.benchmark(2)).to_not eq(nil)
    end

    it 'return-type for benchmark is hash with expected keys' do
      return_type = @my_solver.benchmark(2)

      expect(return_type.class).to eq(Hash)
      expect(return_type[:total_time].class).to eq(Float)
      expect(return_type[:avg_time].class).to eq(Float)
      expect(return_type[:avg_turns].class).to eq(Float)
      expect(return_type[:max_turns].class).to eq(Integer)
      expect(return_type[:num_tests]).to eq(2)
    end

    it 'benchmark method only accepts positive numbers' do
      try_zero     = @my_solver.benchmark(0)
      try_negative = @my_solver.benchmark(-1)
      try_letter   = @my_solver.benchmark('a')
      try_nil      = @my_solver.benchmark(nil)

      expect(try_zero).to include(:error)
      expect(try_negative).to include(:error)
      expect(try_letter).to include(:error)
      expect(try_nil).to include(:error)
    end

    it 'can perform .solve after .benchmark(integer)' do
      expect(@my_solver.benchmark(2).length).to eq(5)
      expect(@my_solver.solve.length).to eq(2)
    end

    it 'prints correct answer in color on solve' do
      correct_answer = @my_solver.solve
      expect(color_print(correct_answer[0]).include?('['.white)).to eq(true)
    end
  end
end
