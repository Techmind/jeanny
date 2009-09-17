
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

include Jeanny::Sugar

# analyze(['~/projects/yandex/serp-xsl/block/*/*.css', '~/projects/yandex/serp-xsl/core/*.css'], :compare_with => 'classes.saved') and save
