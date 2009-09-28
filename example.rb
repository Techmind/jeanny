#!/usr/bin/env ruby

require 'rubygems'
require 'jeanny'

include Jeanny::Sugar

analyze('serp/css/_*.css', :compare_with => 'classes.saved') and save

group :css, :title => 'replacing in stylesheets' do
    replace :include => ['serp/css/_*.css', 'serp/block/*/*.css']
end

group :js, :title => 'replacing in scripts' do
    replace :in => 'serp/js/_serp.js'
end

group :html, :title => 'replacing in template files' do
    replace :in => 'serp/static/*.html'
end