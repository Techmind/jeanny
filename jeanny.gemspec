spec = Gem::Specification.new do |gem|
    
    gem.name            = 'jeanny-tpl-fork'
    gem.version         = '0.99.4'
    gem.summary         = 'Lib for obfuscation css class names'
    # gem.description     = 'Lib for obfuscation css class names'
    gem.files           = ['README.md', 'lib/jeanny.rb', 'lib/jeanny/engine.rb', 'lib/jeanny/sugar.rb', 'lib/jeanny/extend.rb']
    gem.require_path    = 'lib'
    
    gem.has_rdoc        = true
    gem.rdoc_options    = ['--inline-source', '--charset=UTF-8']
    
    gem.author          = 'Techmind'
    gem.email           = 'bogunov@gmail.com'
    gem.homepage        = 'http://github.com/Techmind/jeanny'
    
end
