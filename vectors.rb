class Vector

  def initialize file
   #@fuzzVector = File.readlines(resource_path(file)).map{|line| line.strip}
   @fuzzVector = File.readlines(file).map{|line| line.strip}
   @length = @fuzzVector.length
   @count = 0
  end

  #def resource_path file
  #  "resources/vectors/" + file
  #end

  #Give the current fuzzVector and rotate to the next one.
  def next_fuzzVector
    attack = @fuzzVector
    @fuzzVector.rotate!
	@count += 1
    return attack
  end
  
  #Reset the count so that has_next? works multiple times.
  def reset_count!
	@count = 0
  end
  
  #Checks whether the entire vecotr list has been traversed.
  def has_next?
	return @count != @length
  end
end
