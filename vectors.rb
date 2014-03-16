class Vector

  def initialize file
   #@fuzzVector = File.readlines(resource_path(file)).map{|line| line.strip}
   @fuzzVector = File.readlines(file).map{|line| line.strip}
  end

  #def resource_path file
  #  "resources/vectors/" + file
  #end

  def next_fuzzVector
    attack = @fuzzVector
    @fuzzVector.rotate!

    return attack
  end
end
