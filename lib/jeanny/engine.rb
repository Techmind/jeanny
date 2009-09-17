module Jeanny

    class Engine
        
        attr_reader :classes
        
        def initialize
            @classes = {}
        end

        # Метод ищет имена классов в переданном списке файлов
        def analyze path

            fail ArgumentError, 'неверный аргумент (пустой)' if path.nil? or path.empty?

            file_list = get_file_list(path)
            
            fail Errno::ENOENT, "анализируемые файлы не найдены" if file_list.nil? or file_list.empty?

            file_meat = ''
            file_list.each do |file|
                file_meat = file_meat + File.open_file(file)
            end
            
            # Удаляем все экспрешены
            file_meat = replace_expressions(file_meat)

            # Удаляем все что в фигурных и простых скобках
            file_meat = file_meat.gsub(/\{.*?\}/m, '{}').gsub(/\(.*?\)/, '()')
            
            # Находим имена классов
            file_meat.gsub(/\.([^\.,\{\} :#\[\]\*\n\s]+)/) do |match|
            
                # Если найденная строка соответствует маске и класс еще не был добавлен — добавляем его
                @classes[$1] = '' if match =~ /^\.([a-z]-.+)$/ and not(classes.has_key?($1)) 
                
            end
            
            fail JeannyNoClassesFound, "похоже, что в анализируемом файле нет классов подходящих по условию" if classes.empty?
            
            true

        end
        
        def compare_with file
            
            fail JeannyCompareFileNotFound, "анализируемый файл не найден" unless File.exists?(File.expand_path(file))
                    
            saved_classes = { }
                    
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
                    
            fail JeannyCompareFileFormatError, "сравниваемый файл пуст или имеет неверный формат" if saved_classes.nil? or not(saved_classes.kind_of?(Hash)) or saved_classes.empty?
            
            (@classes.keys & saved_classes.keys).each do |class_name|
                @classes[class_name] = [saved_classes[class_name], 1]               # restored classes
            end
            
            empty_classes = @classes.select { |key, val| @classes[key].epmty? }
            
            unless empty_classes.nil? or empty_classes.empty?
                
                # Удаляем уже используемые короткие имена из списка
                short_words.delete_if { |x| saved_classes.values.include?(x) }
                
                # И понеслась...
                empty_classes.each_with_index do |key, index|
                    @classes[key[0]] = [short_words[index], 0]                      # new classes
                end
                
            end

        end
        
        def fill_short_class_names
            @classes.keys.each_with_index do |key, index|
                @classes[key] = [short_words[index], 0]                             # new classes
            end
        end
            
        def replace path
            
        end
        
        # private

        # Метод генерирует массив коротких имен.
        # По умолчанию генерируется 38471 имя. Если надо больше, добавить — легко        
        def short_words again = false
            
            if @short_words.nil? or @short_words.empty? or again
                
                @short_words = []
                
                %w(a aa a0 a_ a- aaa a00 a0a aa0 aa_ a_a aa- a-a a0_ a0- a_0 a-0).each do |name|
                    max = name.length + 1
                    while name.length < max
                        @short_words << name
                        name = name.next
                    end
                end
            end
            
            @short_words
            
        end
        
        def get_file_list path
            file_list = []

            file_path = [path].flatten.map do |item|
                File.expand_path(item)
            end
            
            file_path.each do |file|
                file_list << Dir[file]
            end

            file_list.flatten
        end
        
        # Функция пытается найти все экспрешены в css
        # Eсли задан блок, передает экспрешены ему, иначе - просто удаляет
        def replace_expressions(css, &block)
            length = css.length    
            while css.include?('expression(') do
                brake = 0
                start = css.index('expression(');
                block = css[start, length - start]

                block.length.times do |i|
                    char = block[i, 1]
                    if char =~ /\(|\)/
                        brake = brake + 1 if char == '('
                        brake = brake - 1 if char == ')'

                        if brake == 0
                            brake = block[0, i + 1]
                            break
                        end
                    end
                end

                if block_given?
                    result = yield brake
                    css.gsub!(brake, result)
                else
                    css.gsub!(brake, '')
                end
            end

            css
        end

    end

end