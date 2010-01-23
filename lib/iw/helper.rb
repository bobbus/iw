class String
  def to_node
   self.split(" ").map{|x| x.downcase}.join("_")
  end
end
