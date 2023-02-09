require_relative "../test_helper"

module Tracer
  class ObjectTracerTest < TestCase
    include ActivationTests

    def test_object_tracer_arguments_fallback
      obj = Object.new
      tracer = ObjectTracer.new(obj)
      assert_equal(obj.object_id, tracer.target_id)
      assert_equal(obj.inspect, tracer.target_label)

      tracer = ObjectTracer.new(target_id: obj.object_id, target_label: "foo")
      assert_equal(obj.object_id, tracer.target_id)
      assert_equal("foo", tracer.target_label)

      tracer = ObjectTracer.new(target_id: obj.object_id)
      assert_equal(obj.object_id, tracer.target_id)
      assert_equal("<unlabelled>", tracer.target_label)
    end

    private

    def build_tracer
      stub_object = Object.new
      ObjectTracer.new(stub_object, output: @output)
    end
  end

  class ObjectTracerIntegrationTest < IntegrationTestCase
    def test_object_tracer_traces_object_usage
      file = write_file("foo.rb", <<~RUBY)
        obj = Object.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        ObjectTracer.new(obj).start

        bar(obj)
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          %r{#depth:0  #<Object:.*> is used as a parameter obj of Object#bar at .*/foo\.rb:13},
          %r{#depth:1  #<Object:.*> receives \.foo at .*/foo\.rb:8}
        ],
        out
      )
    end

    def test_object_tracer_handles_rest_arguments
      file = write_file("foo.rb", <<~RUBY)
        obj = Object.new

        def foo(*args)
        end

        def bar(**kwargs)
        end

        ObjectTracer.new(obj).start

        foo(obj)
        bar(obj: obj)
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          %r{#depth:0  #<Object:.*> is used as a parameter in args of Object#foo at .*/foo\.rb:11},
          %r{#depth:0  #<Object:.*> is used as a parameter in kwargs of Object#bar at .*/foo\.rb:12}
        ],
        out
      )
    end

    def test_object_tracer_calculates_depth_correctly
      file = write_file("foo.rb", <<~RUBY)
        obj = Object.new

        def foo(*args)
          yield args.first
        end

        def bar(**kwargs)
        end

        ObjectTracer.new(obj).start

        foo(obj) do |obj|
          bar(obj: obj)
        end
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          %r{#depth:0  #<Object:.*> is used as a parameter in args of Object#foo at .*/foo\.rb:12},
          %r{#depth:1  #<Object:.*> is used as a parameter obj of block{} at .*/foo\.rb:4},
          %r{#depth:2  #<Object:.*> is used as a parameter in kwargs of Object#bar at .*/foo\.rb:13}
        ],
        out
      )
    end

    def test_object_tracer_works_with_object_id_and_label
      file = write_file("foo.rb", <<~RUBY)
        obj = Object.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        ObjectTracer.new(target_id: obj.object_id, target_label: obj.inspect).start

        bar(obj)
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          %r{#depth:0  #<Object:.*> is used as a parameter obj of Object#bar at .*/foo\.rb:13},
          %r{#depth:1  #<Object:.*> receives \.foo at .*/foo\.rb:8}
        ],
        out
      )
    end

    def test_object_tracer_works_with_basic_object
      file = write_file("foo.rb", <<~RUBY)
        obj = BasicObject.new

        def obj.foo
          100
        end

        def bar(obj)
          obj.foo
        end

        ObjectTracer.new(obj).start

        bar(obj)
      RUBY

      out, err = execute_file(file)

      assert_empty(err)
      assert_traces(
        [
          %r{#depth:0  #<BasicObject.* does not have #inspect> is used as a parameter obj of Object#bar at .*/foo\.rb:13},
          %r{#depth:1  #<BasicObject.* does not have #inspect> receives \.foo at .*/foo\.rb:8}
        ],
        out
      )
    end
  end
end
