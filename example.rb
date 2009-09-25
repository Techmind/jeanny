#!/usr/bin/env ruby

require 'lib/jeanny'

include Jeanny::Sugar

analyze('test.css', :compare_with => 'classes.saved') and save

group :css, :title => 'replacing in stylesheets' do
    replace :in => 'serp/css/_*.css'
end

group :js, :title => 'replacing in scripts' do
    replace :in => 'serp/js/_serp.js'
end

group :html, :title => 'replacing in template files' do
    replace :in => ['serp/static/*.html']
end