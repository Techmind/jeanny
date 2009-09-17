require 'singleton'

module Jeanny

    module Sugar

        # Singleton класс который взаимодействует c Jeanny
        class BridgeToJeanny

            include Singleton

            def initialize
                refresh
            end

            def analyze(path, args = {})

                begin
                    if @engine.analyze(path)
                        @canbe[:save], @canbe[:process] = true
                        @canbe[:analyze] = false
                    end                
                rescue ArgumentError, RuntimeError, Errno::ENOENT => e
                    $stderr.puts "Ошибка: ".red + e.message
                    exit 0
                end
                
                compare_file = args[:compare_with]
                
                unless compare_file.nil?
                    begin
                        @engine.compare_with(compare_file) unless compare_file.empty?
                    rescue JeannyCompareFileNotFound, JeannyCompareFileFormatError => e
                
                        $stderr.puts "Внимание: ".yellow + e.message
                
                        action = ''
                
                        while not(%w(y n yes no).include?(action))
                            print "Продолжить выполнение (y/n): "
                            action = gets.chomp!
                        end
                
                        if %w(n no).include?(action)
                            $stderr.puts "  Работа завершена"
                            exit 1
                        else
                            $stdout.puts "  Продолжаем без сравнивания"
                        end
                
                        compare_file = ''
                        retry
                    rescue RuntimeError => e
                        $stderr.puts "Ошибка: ".red + e.message
                        exit 0
                    end
                else
                    @engine.fill_short_class_names
                end

                true
            end

            def save file = ''
                puts "Saving file to: #{file}"
            end

            def save_to file
                save file
            end

            private

            attr_reader :analyze_file, :compare_file
            attr_reader :engine
            attr_reader :canbe

            attr_reader :process_block_start
            attr_reader :process_block

            def refresh

                @engine = Engine.new
                @file_list, @compare_file = '', ''
                @canbe = { :analyze => true, :save => false, :process => false, :replace => false, :stat => false, :make => false }

                # @process_block_start = false
                # @process_block = []
                
            end

        end

        # Тут перехватываем все несуществующие методы. 
        # И те которые используются в DSL отправляем куда надо.
        def method_missing(method, *args, &block)
            BridgeToJeanny.instance.send(method, *args, &block) if BridgeToJeanny.instance.respond_to?(method)
        end

    end

end