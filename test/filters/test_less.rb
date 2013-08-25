# encoding: utf-8

require 'helper'

class Nanoc::Less::FilterTest < Minitest::Test

  def setup
    super

    @item = Nanoc::Item.new(Nanoc::TextualContent.new('blah', File.absolute_path('content/foo/bar.txt')), {}, '/foo/bar.txt')
  end

  def test_filter
    # Create filter
    filter = ::Nanoc::Less::Filter.new(:item => @item, :items => [ @item ])

    # Run filter
    result = filter.run('.foo { bar: 1 + 1 }')
    assert_match(/\.foo\s*\{\s*bar:\s*2;?\s*\}/, result)
  end

  def test_filter_with_paths_relative_to_site_directory
    # Create file to import
    FileUtils.mkdir_p('content/foo/qux')
    File.write('content/foo/qux/imported_file.less', 'p { color: red; }')

    # Create filter
    filter = ::Nanoc::Less::Filter.new(:item => @item, :items => [ @item ])

    # Run filter
    result = filter.run('@import "content/foo/qux/imported_file.less";')
    assert_match(/p\s*\{\s*color:\s*red;?\s*\}/, result)
  end

  def test_filter_with_paths_relative_to_current_file
    # Create file to import
    FileUtils.mkdir_p('content/foo/qux')
    File.write('content/foo/qux/imported_file.less', 'p { color: red; }')

    # Create item
    File.write('content/foo/bar.txt', 'meh')

    # Create filter
    filter = ::Nanoc::Less::Filter.new(:item => @item, :items => [ @item ])

    # Run filter
    result = filter.run('@import "qux/imported_file.less";')
    assert_match(/p\s*\{\s*color:\s*red;?\s*\}/, result)
  end

  def test_recompile_includes
    FileUtils.rm_rf('tmp')
    FileUtils.mkdir_p('tmp')
    FileUtils.cd('tmp') do
      # Create config
      File.write('nanoc.yaml', 'foo: 123')

      # Create two less files
      FileUtils.mkdir('content')
      File.open('content/a.less', 'w') do |io|
        io.write('@import "b.less";')
      end
      File.open('content/b.less', 'w') do |io|
        io.write("p { color: red; }")
      end

      # Update rules
      File.open('Rules', 'w') do |io|
        io.write "compile '/a.less' do\n"
        io.write "  filter :less\n"
        io.write "  write item.identifier.with_ext('css')\n"
        io.write "end\n"
        io.write "\n"
        io.write "compile '/b.less' do\n"
        io.write "  filter :less\n"
        io.write "end\n"
      end

      # Compile
      site = Nanoc::SiteLoader.new.load
      Nanoc::Compiler.new(site).run

      # Check
      assert Dir['output/*'].size == 1
      assert File.file?('output/a.css')
      refute File.file?('output/b.css')
      assert_match(/^p\s*\{\s*color:\s*red;?\s*\}/, File.read('output/a.css'))

      # Update included file
      File.write('content/b.less', 'p { color: blue; }')

      # Recompile
      site = Nanoc::SiteLoader.new.load
      Nanoc::Compiler.new(site).run

      # Recheck
      assert Dir['output/*'].size == 1
      assert File.file?('output/a.css')
      refute File.file?('output/b.css')
      assert_match(/^p\s*\{\s*color:\s*blue;?\s*\}/, File.read('output/a.css'))
    end
  end

  def test_compression
    # Create filter
    filter = ::Nanoc::Less::Filter.new(:item => @item, :items => [ @item ])

    # Run filter with compress option
    result = filter.run('.foo { bar: a; } .bar { foo: b; }', :compress => true)
    assert_match(/^\.foo\{bar:a;\}\n\.bar\{foo:b;\}/, result)
  end

end
