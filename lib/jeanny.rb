
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

analyze('~/projects/yandex/serp-xsl/block/l-page/*.css', :compare_with => 'classes.saved') and save

# group :css, :title => 'replacing in css files' do
#     replace :include => '~/projects/yandex/serp-xsl/css/*.css', :prefix => '!'                              # замена в core.css
#     replace :include => '~/projects/yandex/serp-xsl/block/z-*/*.css', :exclude => %w(l-page l-head l-)      # замена в блоках с префиксом z-
# end
# 
# group :js, :title => 'replacing in js files' do
#     replace :in => '~/projects/yandex/serp-xsl/js/*.js', :exclude => /^swf/, :prefix => '_'
# end

group :html, :title => 'replacing in template files' do
    replace :in => ['~/projects/yandex/serp-xsl/tt2/*.tt2']    
end

# group :qwe, :title => 'replacing in template files' do
#     replace :in => ['~/projects/yandex/serp-xsl/tt2/*.tt2', '~/projects/yandex/serp-xsl/tt2/*/*.tt2']    
# end