#!/usr/bin/env ruby

require 'lib/jeanny'

include Jeanny::Sugar

#analyze(['serp/css/_*.css', 'serp/block/**/*.css'], :compare_with => 'classes.tt2') and save

#group :css, :title => 'replacing in stylesheets' do
    #replace :include => ['serp/css/_*.css', 'serp/block/**/*.css']
#end

#group :js, :title => 'replacing in scripts' do
    #replace :in => 'serp/js/_search.js', :prefix => '_'
    #replace :in => 'serp/block/**/*.js'
#end

#group :html, :title => 'replacing in template files' do
    #replace :in => 'serp/static/*.html'
#end

analyze %w(_search.css) and save 'hello.yaml'

group :tt2 do

    #replace :in => 'serp/tt2/report.tt2'
    #replace :in => 'serp/tt2/snippets/full/video.tt2'
    #replace :in => 'serp/tt2/**/*.tt2', :exclude => /^.+\/_[^\/]+$/, :prefix => "_"

end
