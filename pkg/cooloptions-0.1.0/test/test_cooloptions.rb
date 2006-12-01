# --
# Copyright (c) 2006 Nathaniel Talbott and Terralien, Inc. All Rights Reserved.
# Licensed under the RUBY license.

require 'test/unit'
require 'cooloptions'
require 'stringio'

class TestCoolOptions < Test::Unit::TestCase
  def setup
    @out = CoolOptions.out = StringIO.new
  end

  def parse!(argv, &block)
    CoolOptions.parse!('', argv, &block)
  rescue Exception
    raise if $!.class >= StandardError
    raise "Exception raised: #{$!.inspect}#{"\nOutput:\n" + @out.string if $!.class == SystemExit}"
  end

  def test_should_handle_booleans
    r = parse!(%w(-a --no-b --c)) do |o|
      o.on :a, '[no-]a', 'a', false
      o.on :b, '[no-]b', 'b', true
      o.on :c, '[no-]c', 'c', false
      o.on :d, '[no-]d', 'd', true
    end
    
    assert r.a
    assert !r.b
    assert r.c
    assert r.d
  end
  
  def test_should_handle_strings
    r = parse!(%w(-a b --c=d)) do |o|
      o.on :a, 'a ARG', 'a'
      o.on :c, 'c ARG', 'c'
    end
    
    assert_equal 'b', r.a
    assert_equal 'd', r.c
  end
  
  def test_should_ignore_non_options
    r = CoolOptions.parse!('', argv=%w(ab -c de)) do |o|
      o.on :c, '[no-]c', 'c'
    end
    
    assert r.c
    assert_equal %w(ab de), argv
  end
  
  def test_should_call_after
    called = false
    r = parse!(%w(-a)) do |o|
      o.on :a, '[no-]a', 'a'
      o.after{|r| assert r.a; called=true}
    end
    assert called
  end
  
  def test_should_not_catch_random_errors
    assert_raise(RuntimeError) do
      parse!([]) do |o|
        o.after{raise RuntimeError}
      end
    end
  end
  
  def test_should_output_help
    begin
      r = CoolOptions.parse!('details', %w(--help)) do |o|
        o.on :a, '[no-]a', 'aa'
      end
    rescue SystemExit
      rescued = true
    end

    assert rescued
    assert_equal <<EOH, @out.string
Usage: #{File.basename($0)} details
    -a, --[no-]a                     aa
    -h, --help                       This help info.
EOH
  end
  
  def test_should_require_options_with_no_default
    assert_raise(SystemExit) do
      CoolOptions.parse!([]) do |o|
        o.on :a, 'a A', 'a'
      end
    end
  end
end