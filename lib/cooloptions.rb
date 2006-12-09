# Copyright (c) 2006 Nathaniel Talbott and Terralien, Inc. All Rights Reserved.
# Licensed under the RUBY license.

require 'optparse'
require 'ostruct'

class CoolOptions
  VERSION = '0.2.0'

  class Error < StandardError #:nodoc:
  end

  def self.parse!(*args)
    o = new
    yield o
    o.parse!(*args)
  rescue Error => e
    out.puts e.message
    o.help true
  end
  
  def self.out #:nodoc:
    @out || STDOUT
  end
  
  def out #:nodoc:
    self.class.out
  end
  
  def self.out=(out) #:nodoc:
    @out = out
  end
  
  def initialize
    @options = []
    @after = nil
  end
  
  def on(key, long, message, default=nil, short=nil)
    unless short
      short = if /^\[/ =~ long
        long.split(/\]/).last
      else
        long
      end[0,1]
    end
    @options << [key, short, long, message, default]
  end
  
  def parse!(banner="[options]", argv=ARGV)
    result = {}
    required = []
    OptionParser.new do |o|
      @o = o
      o.banner = "Usage: #{File.basename($0)} #{banner}"

      @options.each do |(key, short, long, message, default)|
        args = ["-#{short}", "--#{long}", message]
        if default.nil?
          required << key
        else
          result[key] = default
          args << "Default is: #{default}"
        end
        o.on(*args){|e| result[key] = e}
      end
      
      o.on('-h', '--help', "This help info."){help}
    end.parse!(argv)
    required.reject!{|e| result.key?(e)}
    error "Missing required options: #{required.join(', ')}" unless required.empty?
    result = OpenStruct.new(result)
    @after.call(result) if @after
    result
  end
  
  def error(message)
    raise Error, message, caller
  end
  
  def after(&after)
    @after = after
  end
  
  def help(error=false)
    out.puts @o
    exit(error ? 1 : 0)
  end
end

