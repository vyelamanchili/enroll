class CmsParentBuilder

  def initialize(data)
    # binding.pry
    @data = data
    @header_row = @data.row(1)
    # @first_row  = @data.first_row + 1 # data starts from second row
    @first_row = 2
    assign_headers
    @last_row = 1000000
  end

  def assign_headers
    @headers = Hash.new
    @header_row.each_with_index {|header,i|
      @headers[header.underscore] = i
    }
  end

end