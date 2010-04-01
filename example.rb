#!/usr/bin/env ruby

require 'lib/jeanny'

include Jeanny::Sugar

app_path = '/WebServers/home/frontlawgui.localhost/www/';
app_path_tpl = app_path + 'tpl/';
app_path_js = app_path + 'static/js/';

css_dirs = [
	app_path + 'static/css/*.css'
]

js_dirs = [
	app_path_js + '*.js',
	app_path_js + '*/*.js',
	app_path_js + '*/*/*.js',
	app_path_js + '*/*/*/*.js'
]
	
template_dirs = [
	app_path_tpl + '*/*.tpl',
	app_path_tpl + '*/*/*.tpl',
	app_path_tpl + '*/*/*/*.tpl',
]

start_match = /^(\/|[a-zA-Z]\:\/)/
to_tmp = '\1tmp/'

key_words_regexp = [/^(first|last|button|input|object|select|textarea|number|selected|value|border|hover|label|title|center|right|toggle|clear|submit|active|search|disabled|enabled|loader)/]

# [TODO] add load from file
analyze(css_dirs, :compare_with => 'css.yaml', :excludes => key_words_regexp) and save 'css.yaml'

group :css, :title => 'replacing in stylesheets' do
     replace :include => css_dirs, :match => start_match, :replace => to_tmp
end

group :js, :title => 'replacing in scripts' do    
    replace :in => js_dirs, :match => start_match, :replace => to_tmp, :exclude => [/sproutcore/, /\.min/, /\jquery-1.4.2/, /\.compliled/]
end

group :tpl, :title => 'replacing in template files' do
    replace :in => template_dirs, :match => start_match, :replace => to_tmp
end

#group :tt2 do
    #replace :in => 'serp/tt2/report.tt2'
    #replace :in => 'serp/tt2/snippets/full/video.tt2'
    #replace :in => 'serp/tt2/**/*.tt2', :exclude => /^.+\/_[^\/]+$/, :prefix => "_"
#end