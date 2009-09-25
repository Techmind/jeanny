require 'rubygems'
require 'ruby-debug'

module Jeanny

    #
    # Класс который выполнят всю основную работу. 
    # Парсит и заменяет классы, сохраняет и сравнивает их.
    #
    class Engine

        attr_reader :classes

        def initialize
            @classes = Dictionary.new
        end

        #
        # Метод ищет имена классов, в переданных ему файлах
        # В качестве path может выступать массив или строка с расположенеим анализируемых файлов. Можно использовать * и ? как в поиске.
        #
        def analyze path
            
            fail ArgumentError, "передан неверный аргумент (Jeanny::Engine.analyze)" if path.nil? or path.empty?

            # получаем «реальный» список файлов который надо проверить
            file_list = File.list path

            fail JeannyFileNotFound, "файлы для анализа не найдены (Jeanny::Engine.analyze)" if file_list.empty?

            file_meat = ''
            file_list.each do |file|
                file_meat = file_meat + File.open_file(file)
            end

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

        def compare_with file

            # Есть:
            #   1. Массив классов из css файлов
            # 
            # Надо:
            #   1. Открыть файл сравнения
            #   2. Достать от туда классы
            #   3. Найти новые классы и добавить их к сохраненным
            #   5. Сгенирировать массив коротких имен, убрать от туда все которые 
            #      используются в сохраненных классах, и для новых добавленных установить
            #      значения из получившегося массива.
            #   6. По возможности сохранить порядок
            #   7. ???
            #   8. Profit

            fail JeannyFileNotFound, "анализируемый файл не найден" unless File.exists?(File.expand_path(file))

            saved_classes = Dictionary.new

            raw_file = File.open_file(file)
            raw_data = raw_file.split("\n")

            raw_data.map do |line|
                line.split(':').map do |hash|
                    hash.strip
                end
            end.each_with_index do |item, index|
                if item.length != 2 or item[1].empty?
                    fail "Какая то ерунда с одим (а может больше) классом. Можно пропустить, но хрен его знает что дальше будет…\n" + "файл: #{file}, строка: #{index}\n#{raw_data[index]}".red 
                else
                    saved_classes[item[0]] = item[1]
                end
            end

            fail JeannyCompareFileFormatError, "сравниваемый файл пуст или имеет неверный формат" if saved_classes.nil? or saved_classes.empty?

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

        # Метод для сохранения классов
        def save file

            File.open(File.expand_path(file), 'w') do |f|
                @classes.each do |key, val|
                    f.puts "#{key}: #{val.rjust(40 - key.length)}"
                end                
            end

        end
        
        def replace path, type
            
            fail "Тип блока не понятный" unless [:js, :css, :html, :plain].include? type
            
            file_list = File.list path
            file_list.each do |file|
                
                data = File.open_file file
                
                code = case type
                    when :js JSCode
                    when :css CSSCode
                    when :html HTMLCode
                    when :plain PlainCode
                end
                
                code = code.new data
                data = code.replace @classes
                
                File.save_file file, data
                
            end
            
        end

        private

        def get_file_list path

            # file_list = []
            # file_path = [path].flatten.map do |item|
            #     File.expand_path(item)
            # end
            # 
            # file_path.each do |file|
            #     file_list << Dir[file]
            # end
            # 
            # file_list.flatten

        end

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

            hash.each_pair { |key, val| append key, val } unless hash.empty?

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