require 'rubygems'
require 'ruby-debug'

module Jeanny

    # Класс который выполнят всю основную работу. 
    # Парсит и заменяет классы, сохраняет и сравнивает их.    
    class Engine

        attr_reader :classes

        def initialize
            @classes = Dictionary.new
        end

        # Метод ищет имена классов, в переданном ему тексте
        def analyze file_meat
            
            fail TypeError, "передан неверный аргумент (Jeanny::Engine.analyze)" if file_meat.empty?

            # Удаляем все экспрешены и удаляем все что в простых и фигурных скобках
            file_meat.remove_expressions!.gsub(/\{.*?\}/m , '{}').gsub(/\(.*?\)/, '()')

            short_words = generate_short_words

            # Находим имена классов
            file_meat.gsub(/\.([^\.,\{\} :#\[\]\*\n\s]+)/) do |match|
                # Если найденная строка соответствует маске и класс еще не был добавлен — добавляем его
                @classes[$1] = short_words.shift if match =~ /^\.([a-z]-.+)$/ and not(@classes.include? $1 ) 
            end

            fail JeannyClassesNotFound, "похоже, что в анализируемом файле нет классов подходящих по условию" if @classes.empty?

            @classes

        end
        
        # Метод сравниваеи найденные классы с переданными в аргументе saved_classes
        # и возвращает имена элементво которых нет в saved_classes
        def compare_with saved_classes

            return if saved_classes.nil? or saved_classes.empty?
            
            saved_classes = Dictionary.new saved_classes
            
            # находим новые классы
            new_classes = ((saved_classes.keys | @classes.keys) - saved_classes.keys)

            @classes = saved_classes

            # генерируем короткие имена и удаляем из них уже используемые
            short_words = generate_short_words - saved_classes.values
            new_classes.each do |class_name|
                @classes[class_name] = short_words.shift
            end

            new_classes

        end
        
        #
        def replace path, type
            
            fail "Тип блока не понятный" unless [:js, :css, :html, :plain].include? type
            
            file_list = File.list path
            file_list.each do |file|
                
                data = File.open_file file
                
                # code = case type
                #     when :js JSCode
                #     when :css CSSCode
                #     when :html HTMLCode
                #     when :plain PlainCode
                # end
                # 
                # code = code.new data
                # data = code.replace @classes
                # 
                # File.save_file file, data
                
            end
            
        end

        private

        # Метод генерирует и возращает массив коротких имен.
        # По умолчанию генерируется 38471 имя. Если надо больше, добавить — легко        
        def generate_short_words again = false

            short_words = []

            %w(a aa a0 a_ a- aaa a00 a0a aa0 aa_ a_a aa- a-a a0_ a0- a_0 a-0).each do |name|
                max = name.length + 1
                while name.length < max
                    short_words << name
                    name = name.next
                end
            end

            short_words

        end

    end

    class Dictionary

        #
        # Этот класс, попытка реализовать что нибудь похожее на упорядоченный хэш
        #

        include Enumerable

        attr_reader :keys, :values

        def initialize hash = {  }
            
            @keys = [ ]
            @values = [ ]

            hash.each_pair { |key, val| append key, val } if hash.kind_of? Hash
            hash.each { |item| append item[0], item[1]  } if hash.kind_of? Array

        end

        def [](key)
            if include? key
                @values[@keys.index(key)]
            else
                nil
            end
        end

        def []=(key, value)
            if include? key
                @values[@keys.index(key)] = value
            else
                append key, value
            end
        end

        def append key, value
            @keys << key
            @values << value
        end

        def include? class_name
            @keys.include? class_name
        end

        alias :has_key? include?

        def empty?
            @keys.empty?
        end

        def each
            @keys.length.times do |i|
                yield @keys[i], @values[i]
            end
        end

        def select_keys_if &block
            array = []
            @keys.length.times do |i|
                need_append = yield @keys[i], @values[i]
                array << @keys[i] if need_append
            end
            array
        end

        def length
            @keys.length
        end

        def last
            unless @keys.empty?
                [@keys.last, @values.last]
            end
        end

        def to_s
            each do |key, val|
                puts key.ljust(40) + val
            end
        end

    end

end