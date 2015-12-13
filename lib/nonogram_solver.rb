require "pp"

module Nonogram_Solver
  class Nonogram
    attr_reader :data
    def initialize(sizes, conditions, default = [])
      @sizes = sizes
      @data = Array.new(sizes[0]) { |_| Array.new(sizes[1], nil) }
      @flags = [Array.new(sizes[0], false), Array.new(sizes[1], false)]
      @conditions = conditions
      @default = default
      default.each do |a|
        @data[a[0]][a[1]] = true
      end
    end


    def search_all
      until @flags.flatten.all?
        (0...@sizes[0]).each do |i|
          search_line(i)
        end
        transpose
        (0...@sizes[0]).each do |i|
          search_line(i)
        end
        transpose
      end
    end

    def transpose
      @data = @data.transpose
      @sizes = [@sizes[1], @sizes[0]]
      @flags = [@flags[1], @flags[0]]
      @conditions = [@conditions[1], @conditions[0]]
    end


    def search_line(line)
      puts "do #{line}"
      puts ""
      return @data[line] if @flags[0][line]
      if @data[line].include?(nil).!
        @flags[0][line] = true
        return @data[line]
      end

      condition_num = @conditions[0][line].size
      condition = @conditions[0][line].dup
      condition << 0
      candidate = []
      black_count = condition.inject(0, :+)
      white_count = @sizes[1] - black_count

      white_pos =
        if condition[0] == 0
          [[0, white_count]]
        else
          ans = [1] * (condition_num - 1)
          ans.push(0)
          ans.unshift(0)
          white_pos = (0..(white_count - (condition_num - 1))).to_a
          .repeated_combination(condition_num + 1).to_a
          .lazy.select { |a|
            a.inject(0, :+) == white_count - (condition_num - 1)
          }.map { |a|
            a.permutation.to_a.uniq
          }.to_a.flatten(1)

          white_pos = white_pos.lazy.map { |a|
            a.zip(ans).map! { |i| i.inject(0, :+) }
          }.to_a
        end

      white_pos.each { |a|
        tmp_candidate = []
        condition.size.times { |i|
          tmp_candidate << [false] * a[i]
          tmp_candidate << [true] * condition[i]
        }
        candidate << tmp_candidate.flatten
      }
      candidate.select! { |a|
        (0...a.size).each do |i|
          break false if a[i] == true && @data[line][i] == false
          break false if a[i] == false && @data[line][i] == true
          true
        end
      }
      ans = candidate.transpose.map { |a|
        a.uniq.size == 1 ? a[0] : nil
      }
      @flags[0][line] = true if ans.include?(nil).!
      @data[line] = ans
      print_data
    end


    def print_data
      puts @data.map { |a| a.map { |i|
          case i
          when true then "■"
          when false then "  "
          else "？"
          end
        } * "" 
      } * "\n"
      puts ""
    end
  end
end



if $0 == __FILE__
  include Nonogram_Solver
  # default = [[4, 0], [1, 2]]
  # conditions = [
    # [[1], [4], [0], [1], [1, 1]],
    # [[1, 1], [2], [1, 2], [1]]
  # ]
  # pp obj = Nonogram_Solver::Nonogram.new([5, 4], conditions, default)
  # puts obj.print_data
  # obj.search_all(false)
  # # obj.search_line(4)
  # puts obj.print_data
  # pp obj
  

  default = [
    [3, 3], [3, 21], [4, 16], [4, 21],
    [6, 8], [8, 16], [9, 8], [9, 21],
    [10, 8], [11, 3], [12, 3], [13, 16],
    [14, 8], [14, 21], [15, 21], [17, 8],
    [18, 8], [18, 16], [20, 3], [20, 21],
    [21, 3], [21, 21]
  ]

  conditions = [
    [[7, 1, 3, 2, 1, 1],
    [1, 1, 2, 2, 2, 6, 1],
    [1, 3, 1, 4, 3, 3],
    [1, 3, 1, 1, 1, 2, 1, 1, 4],
    [1, 3, 1, 3, 7, 1],
    [1, 1, 1, 1, 4],
    [7, 1, 4, 1, 1, 3],
    [6, 2, 1],
    [1, 3, 3, 2, 1, 8, 1],
    [2, 2, 1, 1, 1, 1, 1, 2, 1],
    [1, 2, 5, 2, 2],
    [3, 3, 1, 1, 1, 3, 1],
    [4, 1, 1, 2, 6],
    [1, 2, 3, 1, 1, 1, 1, 1],
    [1, 7, 3, 2, 1],
    [2, 2, 1, 2, 1, 1, 1, 2],
    [2, 1, 2, 1, 8, 2, 1],
    [1, 1, 3],
    [7, 1, 1, 1, 1, 1, 7],
    [1, 1, 1, 2, 1, 1],
    [1, 3, 1, 1, 4, 1, 3, 1],
    [1, 3, 1, 1, 5, 1, 3, 1],
    [1, 3, 1, 3, 1, 3, 1, 3, 1],
    [1, 1, 2, 2, 1, 1],
    [7, 2, 1, 1, 7],],

    [[7, 1, 1, 3, 7],
    [1, 1, 2, 2, 1, 1],
    [1, 3, 1, 1, 3, 1, 3, 1],
    [1, 3, 1, 6, 1, 1, 3, 1],
    [1, 3, 1, 2, 5, 1, 3, 1],
    [1, 1, 2, 1, 1],
    [7, 1, 1, 1, 1, 1, 7],
    [3, 3],
    [2, 1, 1, 3, 1, 1, 3, 2, 1],
    [1, 1, 2, 3, 1, 1],
    [2, 1, 2, 4, 1, 4],
    [3, 1, 4, 1, 1, 1, 1, 1],
    [5, 2, 1, 1, 1, 2],
    [1, 3, 6, 2, 2, 3],
    [1, 2, 1, 1, 9, 1],
    [1, 3, 2, 2, 1, 2],
    [1, 5, 1, 1, 1, 1, 3],
    [5, 2, 2, 1],
    [3, 1, 1, 1, 2, 1, 7],
    [1, 2, 2, 1, 2, 1, 1],
    [1, 5 ,4, 1, 3, 1],
    [2, 10, 3, 1, 3, 1],
    [6, 6, 1, 1, 3, 1],
    [2, 1, 1, 2, 1, 1],
    [5, 2, 1, 2, 7],]
  ]

  nonogram = Nonogram_Solver::Nonogram.new([25, 25], conditions, default)
  nonogram.print_data
  nonogram.search_all

  nonogram.print_data
end
