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

            # p file_meat
            
            # Удаляем все экспрешены
            file_meat = replace_expressions(file_meat) do |expression|
                ''
            end

            # Удаляем все что в фигурных и простых скобках
            file_meat = file_meat.gsub(/\{.*?\}/m, '{}').gsub(/\(.*?\)/, '()')
            
            # Находим имена классов
            file_meat.gsub(/\.([^\.,\{\} :#\[\]\*\n\s]+)/) do |match|
            
                # Если найденная строка соответствует маске и класс еще не был добавлен — добавляем его
                @classes[$1] = '' if match =~ /^\.([a-z]-.+)$/ and not(@classes.has_key?($1)) 
                
            end
            
            fail JeannyNoClassesFound, "похоже, что в анализируемом файле нет классов подходящих по условию" if @classes.empty?
            
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
            
            short_words = generate_short_words

            empty_classes = @classes.select { |key, val| val.empty? }
            
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
            
            short_words = generate_short_words
            
            @classes.keys.each_with_index do |key, index|
                @classes[key] = [short_words[index], 0]                             # new classes
            end
            
        end
            
        def replace type, struct
            
            fail "Тип блока не понятный" unless [:js, :css, :html, :plain].include? type
            
            struct.each do |struct_item|
                file_list = get_file_list struct_item[:in]
                file_list.delete_if do |path|
                    
                    delete = false
                    
                    struct_item[:ex].each do |exclude_rule|
                        
                        if exclude_rule.kind_of? Regexp
                            delete = File.basename(path) =~ exclude_rule
                        else
                            delete = File.basename(path).include?(exclude_rule)
                        end
                        
                        break if delete
                    end
                    
                    delete
                    
                end
                
                file_list.each do |path|
                    
                    data = File.open_file(path)
                    
                    code = case type
                        when :js then JSCode
                        when :css then CSSCode
                        when :html then HTMLCode
                    end
                    
                    code = code.new data
                    data = code.replace @classes
                    
                    File.save_file(path, data)
                    
                end
                
            end
            
        end
        
        def save file
            file = File.expand_path(file)
            data = @classes.map { |x| [x[0], x[1][0]].join(': ') }.sort_by { |x| x }.join("\n")
            
            File.save_file(file, data)
        end
        
        private

        # Метод генерирует массив коротких имен.
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
    
    class Code
        
        attr_reader :code
        
        def initialize code
            @code = code
        end
        
        def replace classes
            
        end
        
    end
    
    class JSCode < Code
        
        def replace classes
            
            classes = classes.to_a.sort_by { |x| x[0].length }.reverse
            
            # Находим все строки и регулярные выражения
            @code.gsub(/(("|'|\/)((\\\2|.)*?)\2)/m) do |string|

                string_before, string_after = $3, $3

                # Проходимся по всем классам
                classes.each do |class_name|

                    # И заменяем старый класс, на новый
                    string_after = string_after.gsub(class_name[0], class_name[1][0])
                end

                string.gsub(string_before, string_after.gsub(/(\\+)("|')/, "\\1\\1\\2"))

            end
            
        end
        
    end
    
    class CSSCode < Code
        
        def replace classes
            
            classes = classes.to_a.sort_by { |x| x[0].length }.reverse
            
            # Случайная строка
            unique_string = Time.now.object_id.to_s

            # Проходимся по классам
            classes.each do |class_name|

                # Заменяем старое имя класса на новое, плюс случайное число,
                # чтобы знать что этот класс мы уже изменяли
                @code = @code.gsub(/\.#{class_name[0]}(?=[^-\w])/, ".#{unique_string}#{class_name[1][0]}")
            end

            # После замены имен классов, случайное число уже не нужно,
            # так что удаляем его, и возвращаем css с замененными значениями
            @code.gsub(unique_string, '')
            
        end
        
    end
    
    class HTMLCode < Code
        
        def replace classes
            
            # # p classes
            # # Находим в файле текст, типа: class = "some text here..."
            # @code = @code.gsub(/class\s*=\s*('|")(.*?)\1/) do |match|
            # 
            #     # берем то что в кавычках и разбиваем по пробелам
            #     match = $2.split(' ')
            # 
            #     # проходимся по получившемуся массиву
            #     match.map! do |class_name|
            #         # удаляем проблелы по бокам
            #         class_name = class_name.strip
            # 
            #         # и если в нашем списке замены есть такой класс
            #         if classes.has_key? class_name
            #             # заменяем на новое значение
            #             classes[class_name][0]
            #         else
            #             # или оставляем как было
            #             class_name
            #         end
            #     end
            #     
            #     "class=\"#{match.join(' ')}\""
            #     
            # end
            # 
            # @code
            
            # Заменяем классы во встроенных стилях
            @code.gsub!(/<style[^>]*?>(.*?)<\s*\/\s*style\s*>/mi) do |style|
                style.gsub($1, CSSCode.new($1).replace(classes))
            end

            # Заменяем классы во встроенных скриптах
            @code.gsub!(/<script[^>]*?>(.*?)<\s*\/\s*script\s*>/mi) do |script|
                script.gsub($1, JSCode.new($1).replace(classes))
            end
            
            # Находим тэги у которых есть классы, типа: class = "some text here..."
            @code.gsub!(/class\s*=\s*('|")(.*?)\1/) do |match|
            
                # берем то что в кавычках и разбиваем по пробелам
                match = $2.split(' ')
            
                # проходимся по получившемуся массиву
                match.map! do |class_name|
                    # удаляем проблелы по бокам
                    class_name = class_name.strip
            
                    # и если в нашем списке замены есть такой класс
                    if classes.has_key? class_name
                        # заменяем на новое значение
                        classes[class_name][0]
                    else
                        # или оставляем как было
                        class_name
                    end
                end
                
                "class=\"#{match.join(' ')}\""
                
            end
            
            # Находим тэги с аттрибутами в которых может быть js
            @code.gsub!(/<[^>]*?(onload|onunload|onclick|ondblclick|onmousedown|onmouseup|onmouseover|onmousemove|onmouseout|onfocus|onblur|onkeypress|onkeydown|onkeyup|onsubmit|onreset|onselect|onchange)\s*=\s*("|')((\\\2|.)*?)\2[^>]*?>/mi) do |tag|
                tag.gsub($3, JSCode.new($3).replace(classes))
            end

            # # Находим тэги у которых есть классы
            # @code.gsub!(/<[^>]*?class\s*=\s*("|')(.*?)\1[^>]*?>/i) do |tag|
            # 
            #     value_before, value_after = $2, ''
            # 
            #     # Удаляем пробелы в начале, в конце, удаляем табы и переводы 
            #     # стоки и заменяем двойные пробелы на одинарные
            #     value_after = value_before.to_s.gsub(/^\s+/m, '').gsub(/\s+$/m, '').gsub(/\t|\n/m, '').gsub(/ +/, ' ')
            # 
            #     # Разбиваем строку в массив, проходим по нему и если есть 
            #     # такой класс, заменяем его на новый, иначе оставляем старый. Объединяем массив
            #     value_after = value_after.split.map { |class_name| class_name = @class_hash[class_name] || class_name }.join(' ')
            # 
            #     # Возвращаем найденый тэг заменяя класс на новые
            #     tag.gsub(value_before, value_after)
            # end
            
        end
        
    end

end