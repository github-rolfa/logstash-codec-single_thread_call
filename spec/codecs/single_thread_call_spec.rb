# encoding: utf-8
#
require "logstash/devutils/rspec/spec_helper"
require "logstash/codecs/single_thread_call"
require "logstash/event"

describe LogStash::Codecs::SingleThreadCall do
  subject do
    next LogStash::Codecs::SingleThreadCall.new
  end

  let (:message) { "2015-01-01 11:11:11 (http-10.12.12.15-thread1) some information" }

  it "should parse decode lines" do
    subject.decode(message) do |e|
#      expect(e.)
    end
  end

end
