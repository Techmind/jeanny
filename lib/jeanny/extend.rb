class Module
    
    # Проверка наличия метода
    def jeanny_extension(method)
        if method_defined?(method)
            $stderr.puts "WARNING: Possible conflict with jeanny extension: #{self}##{method} already exists"
        else
            yield
        end
    end

end

class File

    jeanny_extension('open_file') do
        # Метод для чтения файла
        def self.open_file(file)
            # Если файл существует
            if exists?(expand_path(file))
                # Открываем, читаем, объединяем, возвращаем содержимое
                # open(expand_path(file), 'r').readlines.join
                open(expand_path(file), 'r').read
            else
                # Возвращаем пустую строку
                raise Errno::ENOENT, "Файл не найден: #{expand_path(file)}"
            end
        end
    end

    jeanny_extension('open_file') do
        # Метод для сохранения файла
        def self.save_file(file, data, prefix = '')
            # Если префикс не пустой, добавляем его к имени файла
            file = "#{dirname(expand_path(file))}/#{prefix}#{basename(file)}" unless prefix.empty?
            # Открываем файл
            open(file, 'w') do |file|
                # Помещаем данные
                file.puts data
            end
        end
    end

end

class String

    jeanny_extension('colorize') do
        # Функция для подсвечивания строки с помошью ANSI кодов…
        def colorize(color_code)
            unless PLATFORM =~ /win32/
                "#{color_code}#{self}\e[0m"
            else
                self
            end
        end
    end

    jeanny_extension('red') do
        # … красным
        def red; colorize("\e[31m"); end
    end

    jeanny_extension('green') do
        # … зеленым цветом
        def green; colorize("\e[32m"); end
    end

    jeanny_extension('yellow') do
        # … и желтым
        def yellow; colorize("\e[33m"); end
    end

end

module Jeanny
    
    %w(CompareFileNotFound CompareFileFormatError NoClassesFound).each { |error| eval "class Jeanny#{error} < RuntimeError; end" }
    
end