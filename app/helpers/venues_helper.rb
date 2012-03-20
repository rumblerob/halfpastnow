module VenuesHelper
  def to_ordinal(num)
    return num.to_s + @ordinal[num%10]
  end
end
