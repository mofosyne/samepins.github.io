#!/usr/bin/env ruby

=begin "create new post.bat":
cd ./samepins.github.io/

@echo on
set /p title="title: " %=%
set /p category="category: " %=%

.\bin\jekyll-page.win.rb "%title%" %category%

PAUSE
=end

# symlink commented out because I use windows D:

require 'date'
require 'optparse'

options = {
    # Expects to be in the bin/ sub-directory by default
    :path => File.dirname(File.dirname(__FILE__))
}

parser = OptionParser.new do |opt|
    opt.banner = 'usage: jekyll-page TITLE CATEGORY [FILENAME] [OPTIONS]'
    opt.separator ''
    opt.separator 'Options'
    opt.on('-e', '--edit', 'Edit the page') do |edit|
        options[:edit] = true
    end
    opt.on('-l', '--link', 'Relink pages') do |link|
        options[:link] = true
    end
    opt.on('-p PATH', '--path PATH', String, 'Path to project root') do |path|
        options[:path] = path
    end
    opt.separator ''
end

parser.parse!

title = ARGV[0]
category = ARGV[1]
filename = ARGV[2]

# Resolve any relative links
BASE_DIR = File.expand_path(options[:path])
POSTS_DIR = "#{BASE_DIR}/_posts"
PAGES_DIR = "#{BASE_DIR}/_pages"

# Ensure the _posts directory exists (we are in the correct directory)
if not Dir.exists?(POSTS_DIR)
    puts "#{POSTS_DIR} directory does not exists"
    exit
end

# Create _pages directory if it doesn't exist
if not Dir.exists?(PAGES_DIR)
    Dir.mkdir(PAGES_DIR)
end

if options[:link]
    Dir.foreach(POSTS_DIR) do |name|
        next if name[0] == '.'
        nodate = name[/\d{4}-\d{2}-\d{2}-(?<rest>.*)/, 'rest']
        #if File.symlink?("#{PAGES_DIR}/#{nodate}")
        #    File.delete("#{PAGES_DIR}/#{nodate}")
        #end
        abspath = File.absolute_path("#{POSTS_DIR}/#{name}")
        #File.symlink(abspath, "#{PAGES_DIR}/#{nodate}")
    end
end

if not title or not category
    # This flag can be used by itself, exit silently if no arguments
    # are defined
    if not options[:link]
        puts parser
    end
    exit
end

if not filename
    filename = title.downcase.gsub(/[^a-z0-9\s]/, '').gsub(/\s+/, '-')
end

today=Date.today().strftime('%F')
now=DateTime.now().strftime('%F %T')

filepath = "#{POSTS_DIR}/#{today}-#{filename}.md"
#symlink = "#{PAGES_DIR}/#{filename}.md"

if File.exists?(filepath)
    puts "File #{filepath} already exists"
    exit
end

content = <<END
---
layout: page
title: \"#{title}\"
category: #{category}
date: #{now}
---


END

File.open(filepath, 'w') do |file|
    file.puts content
end

#File.symlink(File.absolute_path(filepath), symlink)

if options[:edit]
    if not ENV['EDITOR']
        puts 'No $EDITOR variable set'
        exit
    end
    puts ENV['EDITOR']
    exec("#{ENV['EDITOR']} #{filepath}")
end
