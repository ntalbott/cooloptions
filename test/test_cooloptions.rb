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
      o.on 'a', 'a', false
      o.on 'b', 'b', true
      o.on 'c', 'c', false
      o.on 'd', 'd', true
    end
    
    assert r.a
    assert !r.b
    assert r.c
    assert r.d
  end
  
  def test_should_handle_strings
    r = parse!(%w(-a b --c=d)) do |o|
      o.on 'a ARG', 'a'
      o.on 'c ARG', 'c'
    end
    
    assert_equal 'b', r.a
    assert_equal 'd', r.c
  end
  
  def test_should_ignore_non_options
    r = CoolOptions.parse!('', argv=%w(ab -c de)) do |o|
      o.on 'c', 'c'
    end
    
    assert r.c
    assert_equal %w(ab de), argv
  end
  
  def test_should_call_after
    called = false
    r = parse!(%w(-a)) do |o|
      o.on 'a', 'a'
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
        o.on 'a', 'aa'
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
        o.on 'a A', 'a'
      end
    end
    assert_nothing_raised do
      CoolOptions.parse!([]) do |o|
        o.on 'a A', 'a', nil
      end
    end
  end
  
  def test_should_allow_specification_of_alternate_short_form
    r = parse!(%w(-a -b c -c d)) do |o|
      o.on 'a', 'a', false
      o.on 'b)aa VALUE', 'aa'
      o.on 'b(c) VALUE', 'bc'
    end
    assert_equal true, r.a
    assert_equal 'c', r.aa
    assert_equal 'd', r.bc
  end
  
  def test_should_replace_dashes
    r = parse!(%w(--a-b c)) do |o|
      o.on 'a-b A', 'a'
    end
    assert_equal 'c', r.a_b
  end
  
  def test_should_provide_access_to_the_parser
    called = false
    r = parse!(%w(-d)) do |o|
      o.parser.on('-d'){called = true}
    end
    assert called
  end
end