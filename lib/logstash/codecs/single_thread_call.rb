# encoding: utf-8
require "logstash/codecs/base"
require "logstash/codecs/aggregator"

# Add any asciidoc formatted documentation here
class LogStash::Codecs::SingleThreadCall < LogStash::Codecs::Base

  # This example codec will append a string to the message field
  # of an event, either in the decoding or encoding methods
  #
  # This is only intended to be used as an example.
  #
  # input {
  #   stdin { codec => example }
  # }
  #
  # or
  #
  # output {
  #   stdout { codec => example }
  # }
  config_name "single_thread_call"

  # Append a string to the message
  config :start_expr, :validate => :string, :required => true

  config :end_expr, :validate => :string, :required => true

  config :thread_expr, :validate => :string, :required => true

  public
  def register
    @logger.debug("initializing aggregator")
    @aggregator = Aggregator.new(@start_expr, @end_expr, @thread_expr)
    @logger.debug("aggregator initialized")
  end

  public
  def decode(data)
    @logger.debug("decoding #{data}")
    @aggregator.decode(data) do |event|
      @logger.debug("yielding #{event}")
      yield event
    end
  end # def decode

  public
  def encode(event)
    @on_event.call(event, event["message"].to_s)
  end # def encode

end # class LogStash::Codecs::Example
