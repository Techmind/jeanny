
# 
#  jeanny.rb
#  jeanny
#  
#  Created by seriously drunken on 2009-09-16.
#  Copyright 2009 Yandex. All rights reserved.
# 

$:.unshift File.dirname(__FILE__) unless $:.include? File.dirname(__FILE__)
 
module Jeanny

    JEANNY_VERSION = '0.8'

end

require 'jeanny/extend'
require 'jeanny/engine'
require 'jeanny/sugar'

# USAGE ######################################################

# include Jeanny::Sugar

# analyze('serp/css/_core.css', :compare_with => 'classes.saved') and save_to 'classes.saved'

# analyze 'serp/css/_core.css'
# 
# group :css, :title => 'replacing in stylesheets' do
#     replace :in => 'serp/css/_core.css'
# end
# 
# group :js, :title => 'replacing in scripts' do
#     replace :in => 'serp/js/_serp.js'
# end
# 
# group :html, :title => 'replacing in template files' do
#     replace :in => ['serp/static/*.html']
# end

html = File.open('serp/static/z-image.html').readlines.join
html.gsub(/<[^>]*?(onload|onunload|onclick|ondblclick|onmousedown|onmouseup|onmouseover|onmousemove|onmouseout|onfocus|onblur|onkeypress|onkeydown|onkeyup|onsubmit|onreset|onselect|onchange)\s*=\s*("|')((\\\2|.)*?)\2[^>]*?>/mi) do |tag|
    # puts tag
    # puts "\t#{$3.gsub(/\\-/, '-')}"
    puts tag.gsub($3, 'alert(\'Hello\')')
    puts
end