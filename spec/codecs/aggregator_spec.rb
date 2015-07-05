require 'rspec'
require "./aggregator"

describe 'Combine Logs to Call' do

  subject do
    next Aggregator.new(/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d \(.*\) start.*/,
                        /\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d \(.*\) finished.*/,
                        /.* \((.*)\).*/)
  end

  it 'should detect corresponding lines' do

    lines = [
        '2015-01-01 11:11:17 (10.12.12.10-http-5) finished took 21 ms', # 0
        '2015-01-01 11:11:11 (10.12.12.10-http-4) no start here', # 1
        '2015-01-01 11:11:12 (10.12.12.10-http-6) start of something Method', # 2
        '2015-01-01 11:11:14 (10.12.12.10-http-5) start of something Method2', # 3
        '2015-01-01 11:11:15 (10.12.12.10-http-6) doing', # 4
        '2015-01-01 11:11:11 (10.12.12.10-http-4) finished', # 5
        '2015-01-01 11:11:15 (10.12.12.10-http-3) doing', # 6
        '2015-01-01 11:11:16 (10.12.12.10-http-5) doing method 2', # 7
        '2015-01-01 11:11:15 (10.12.12.10-http-3) start of something', # 8
        '2015-01-01 11:11:17 (10.12.12.10-http-5) finished took 101 ms', # 9
        '2015-01-01 11:11:18 (10.12.12.10-http-6) finished took 100 ms' # 10
    ]

    subject.decode(lines[0]) do |e|
      expect(e).not_to be_nil
      expect(e['message']).to eq('2015-01-01 11:11:17 (10.12.12.10-http-5) finished took 21 ms')
    end

    subject.decode(lines[1]) do |e|
      expect(e['message']).to be_nil
    end

    subject.decode(lines[2]) do |e|
       expect(e['message']).to be_nil
    end

    subject.decode(lines[3]) do |e|
      expect(e['message']).to be_nil
    end

    subject.decode(lines[4]) do |e|
      expect(e['message']).to be_nil
    end

    subject.decode(lines[5]) do |e|
      expect(e).not_to be_nil
      expect(e['message']).to eq([lines[1], lines[5]].join('|'))
    end

    subject.decode(lines[6]) do |e|
      expect(e['message']).to be_nil
    end

    subject.decode(lines[7]) do |e|
      expect(e['message']).to be_nil
    end

    subject.decode(lines[8]) do |e|
      expect(e).not_to be_nil
      expect(e['message']).to eq(lines[6])
    end

    subject.decode(lines[9]) do |e|
    expect(e).not_to be_nil
    expect(e['message']).to eq([lines[3], lines[7], lines[9]].join('|'))
    end

    subject.decode(lines[10]) do |e|
      expect(e).not_to be_nil
      expect(e['message']).to eq([lines[2], lines[4], lines[10]].join('|'))
    end

  end
end