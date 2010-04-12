#!/usr/bin/env ruby

require 'lib/jeanny'

include Jeanny::Sugar

if RUBY_PLATFORM == 'linux'
	app_path = '/apps/flg/';
else
	app_path = 'C:/WebServers/home/frontlawgui.localhost/www/';
end

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

start_match_css = /^(\/|[a-zA-Z]\:\/).*\/(css)/
start_match_tpl = /^(\/|[a-zA-Z]\:\/).*\/(tpl)/
start_match_js  = /^(\/|[a-zA-Z]\:\/).*\/(js)/
to_tmp = '\1tmp/jeanny_processed/\2/'

to_processed = app_path + 'cache/processed_tpl/'

key_words_regexp = [/^(first|last|button|input|object|select|textarea|number|selected|value|border|hover|label|title|center|right|toggle|clear|submit|active|search|disabled|enabled|loader)/]

analyze(css_dirs, :compare_with => 'css.yaml', :excludes => key_words_regexp) and save 'css.yaml'

group :css, :title => 'replacing in stylesheets' do
     replace :include => css_dirs, :match => start_match_css, :replace => to_tmp
end

group :js, :title => 'replacing in scripts' do    
    replace :in => js_dirs, :match => start_match_js, :replace => to_tmp, :exclude => [/sproutcore/, /\.min/, /\jquery-1.4.2/, /\.compliled/]
end

group :tpl, :title => 'replacing in template files' do
    replace :in => template_dirs, :match => start_match_tpl, :replace => to_processed
end

#group :tt2 do
    #replace :in => 'serp/tt2/report.tt2'
    #replace :in => 'serp/tt2/snippets/full/video.tt2'
    #replace :in => 'serp/tt2/**/*.tt2', :exclude => /^.+\/_[^\/]+$/, :prefix => "_"
#end