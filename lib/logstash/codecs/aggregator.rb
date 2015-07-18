require "logstash/codecs/base"

class Aggregator

  def initialize (start_expr, end_expr, thread_expr)
    @start_expr = start_expr
    @end_expr = end_expr
    @thread_expr = thread_expr
    @separator = '|'
    @calls = {}
  end

  def decode(data)
    # can we extract the thread id
    if match = data.match(@thread_expr)
      thread = match.captures[0] # get the thread id
      @calls[thread] = [] unless @calls.has_key?(thread) # make sure we have something to store the lines
      lines = @calls[thread] # lines is an arry containing all lines for one call in a thread
      lines.push(data) # append the line we got

      if data.match(@end_expr) # is this the end of a call
        # return all lines we have for the call and empty lines
        message = lines.join(@separator)
        lines.clear
        yield LogStash::Event.new({"message" => message})
      elsif data.match(@start_expr) # is this the start of a call
        # if we have a new start but the lines where not empty (remember we just added the current line)
        if lines.size > 1
          message = lines[0..-2].join(@separator)
          lines.clear
          lines.push(data) # readd the current line
          yield LogStash::Event.new({"message" => message})
        end
      end
    end
  end

end