
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

include Jeanny::Sugar

analyze('serp/css/_*.css', :compare_with => 'classes.saved') and save

group :css, :title => 'replacing in stylesheets' do
    replace :in => 'serp/css/_*.css'
end

group :js, :title => 'replacing in scripts' do
    replace :in => 'serp/js/_serp.js'
end

group :html, :title => 'replacing in template files' do
    replace :in => ['serp/static/*.html']
end