
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

analyze('serp/css/_temp.css', :compare_with => 'classes.saved') and save

group :css, :title => 'replacing in stylesheets' do
    replace :in => 'serp/block/*/*.css'
end

group :html, :title => 'replacing in template files' do
    replace :in => ['serp/page/*.xsl']
    replace :in => ['serp/block/*/*.xsl']
end