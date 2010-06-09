class Fifo 
  def initialize
    @left = []
    @right = []
  end

  def empty?
    @left.empty? && @right.empty?
  end

  def push(item)
    if empty?
      @left.push(item)
    else
      @right.push(item)
    end
    self
  end

  def pop
    if @left.empty?
      return nil if @right.empty?
      @left = @right.reverse
      @right = []
    end
    @left.pop
  end
end
