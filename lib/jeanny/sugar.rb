require 'singleton'

module Jeanny

    module Sugar

        # Singleton класс который взаимодействует c Jeanny
        class BridgeToJeanny

            include Singleton

            def initialize
                # refresh
            end

            def analyze(path, args = {})
                
                refresh

                begin
                    if @engine.analyze(path)
                        @canbe[:save], @canbe[:process] = true, true
                        @canbe[:analyze] = false
                    end                
                rescue StandardError => e
                    $stderr.puts "Ошибка: ".red + e.message
                    exit 0
                end
                
                compare_file = args[:compare_with]
                
                begin
                    unless compare_file.nil? and compare_file.empty?
                        @compare_file = compare_file
                        @engine.compare_with(compare_file)
                    else
                        compare_file = ''
                    end
                rescue SystemCallError, JeannyCompareFileFormatError => e
        
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
                rescue StandardError => e
                    $stderr.puts "Ошибка: ".red + e.message
                    exit 0
                end
                
                @engine.fill_short_class_names if compare_file.empty?
                
                # unless compare_file.nil? and compare_file.empty?
                #     begin
                #         @engine.compare_with(compare_file) unless compare_file.empty?
                #         @compare_file = compare_file
                #     rescue SystemCallError, JeannyCompareFileFormatError => e
                # 
                #         $stderr.puts "Внимание: ".yellow + e.message
                # 
                #         action = ''
                # 
                #         while not(%w(y n yes no).include?(action))
                #             print "Продолжить выполнение (y/n): "
                #             action = gets.chomp!
                #         end
                # 
                #         if %w(n no).include?(action)
                #             $stderr.puts "  Работа завершена"
                #             exit 1
                #         else
                #             $stdout.puts "  Продолжаем без сравнивания"
                #         end
                # 
                #         compare_file = ''
                #         retry
                #     rescue StandardError => e
                #         $stderr.puts "Ошибка: ".red + e.message
                #         exit 0
                #     end
                # else
                #     @engine.fill_short_class_names
                #     puts "!!!"
                # end
                
                
                @engine.classes.to_a.sort_by { |x| x[0] }.each do |x|
                    if x[1][1] == 0
                       puts  "#{x[0].ljust(40)}- #{x[1][0]}".green
                    else
                       puts "#{x[0].ljust(40)}- #{x[1][0]}".yellow
                    end
                end

                true
            end

            def save file = ''
                
                fail SystemCallError, 'на данном этапе нельзя вызывать сохранение классов' unless canbe[:save]
                
                unless @compare_file.empty? and file.empty?
                    @engine.save(file.empty? ? @compare_file : file)
                end
            
            rescue SystemCallError => e
            
                print "#{'Внимание:'.yellow} #{e.message}. "
            
                action = ''
                while not(%w(y n yes no).include?(action))
                    print "Продолжить выполнение (y/n): "
                    action = gets.chomp!
                end
            
                exit 1 if %w(n no).include?(action)

            end

            def save_to file
                save file
            end
            
            def group type, args = {}, &block
   
                begin
                    
                    fail "We can`t process here..." unless @canbe[:process]
                    fail "Блоки process не должны быть рекурсивными" if @process_block_start
                    fail "Не передан блок" unless block_given?
                    
                    @canbe[:process] = false
                    @canbe[:replace] = true

                    @process_block_start = true
                    @process_block = []

                    yield block
                    
                    @process_block_start = false

                    @canbe[:replace] = false
                    @canbe[:process] = true
                    
                rescue StandardError => e
                    $stderr.puts "Ошибка: ".red + e.message
                    exit 0
                end
                
                begin
                    unless @process_block.empty?
                        @engine.replace type, @process_block
                    end
                rescue StandardError => e
                    $stderr.puts "Ошибка: ".red + e.message
                    exit 0
                end
                
            end
            
            def replace args = { }
                
                fail "We can`t replace here..." unless @canbe[:replace]
                
                struct = { :in => [], :ex => [], :prefix => '' }

                struct[:in] = ([args[:in]] | [args[:include]]).flatten.delete_if { |item| item.nil? or item.empty? }
                struct[:ex] = ([args[:ex]] | [args[:exclude]]).flatten.delete_if { |item| item.nil? or item.empty? }

                struct[:prefix] = args[:prefix] unless args[:prefix].nil?

                @process_block << struct if struct[:in].length > 0
                
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

                @process_block_start = false
                @process_block = []
                
            end

        end

        # Тут перехватываем все несуществующие методы. 
        # И те которые используются в DSL отправляем куда надо.
        def method_missing(method, *args, &block)
            BridgeToJeanny.instance.send(method, *args, &block) if BridgeToJeanny.instance.respond_to?(method)
        end

    end

end