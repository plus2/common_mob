require 'fcntl'
require 'stringio'

module CommonMob
  class ShellError < StandardError
    attr_accessor :result
  end

  module ShellHelper
    def sh(*args,&blk)
      CommonMob::Shell.new(*args,&blk)
    end

    # call ruby, or a ruby command with the environment cleaned of bundler spooge
    def bundler_sh(*args,&blk)
      args.options.without_cleaning_bundler = true
      CommonMob::Shell.new(*args,&blk)
    end
  end

  class Shell
    def debug(*msg)
      AngryMob::Mob.ui.debug "sh: #{msg * ' '}"
    end

    attr_reader :options

    def initialize(*args,&block)
      @block = block
      @options = if Hash === args.last then args.pop else {} end

      unless args.empty?
        @options[:cmd] = args
      end

      @options[:stream] = false unless @options.key?(:stream)
    end

    def execute
      error,out = nil,nil

      # XXX interleave out and err
      rv = popen4(options) {|pid,stdin,stdout,stderr|
        out   = stdout.read
        error = stderr.read
      }
      
      if prefix = options[:prefix]
        if Hash === prefix
          pre_err = prefix[:err]
          pre_out = prefix[:out]
        else
          pre_err = prefix
          pre_out = prefix
        end

        rv.stderr = error.gsub(/^(.*)$/, "#{pre_err}\\1")
        rv.stdout = out.gsub(/^(.*)$/  , "#{pre_out}\\1")
      else
        rv.stderr = error
        rv.stdout = out
      end

      rv
    end

    def run
      execute.ensure_ok!
    end

    def ok?
      execute.ok?
    end

    def to_s
      result = execute
      if result.ok?
        result.stdout.chomp
      else
        ''
      end
    end

    class ShellResult < Struct.new(:process_result, :options, :stderr, :stdout)
      def ok?
        process_result.success?
      end

      def ensure_ok!
        unless ok?
          ex = ShellError.new("unable to run\noptions=#{options.pretty_inspect}\noutput=#{stdout}\nerror=#{stderr}")
          ex.result = self
          raise(ex)
        end
      end
    end

    # This is taken directly from Chef and then modified to suit the needs of Igor.
    #
    # This is taken directly from Ara T Howard's Open4 library, and then 
    # modified to suit the needs of Chef.  Any bugs here are most likely
    # my own, and not Ara's.
    #
    # The original appears in external/open4.rb in its unmodified form. 
    #
    # Thanks Ara!
    def popen4(args={}, &b)

      cmd = args[:cmd]

     
      # Do we wait for the child process to die before we yield
      # to the block, or after?
      #
      # By default, we are waiting before we yield the block.
      args[:stream] ||= false
      

      args[:user] ||= nil
      unless args[:user].kind_of?(Integer)
        args[:user] = Etc.getpwnam(args[:user]).uid if args[:user]
      end

      args[:group] ||= nil
      unless args[:group].kind_of?(Integer)
        args[:group] = Etc.getgrnam(args[:group]).gid if args[:group]
      end


      args[:environment] ||= {}

      # Default on C locale so parsing commands output can be done
      # independently of the node's default locale.
      # "LC_ALL" could be set to nil, in which case we also must ignore it.
      unless args[:environment].has_key?("LC_ALL")
        args[:environment]["LC_ALL"] = "C"
      end

      unless TrueClass === args[:without_cleaning_bundler]
        args[:environment].update('RUBYOPT' => nil, 'BUNDLE_GEMFILE' => nil, 'GEM_HOME' => nil, 'GEM_PATH' => nil)
      end

      if user = args[:as]
        if (evars = args[:environment].reject {|k,v| v.nil?}.map {|k,v| "#{k}=#{v}"}) && !evars.empty?
          env = "env #{evars.join(' ')}"
        else
          env = ''
        end
        
        cmd = "sudo -H -u #{user} #{env} #{cmd}"
      end

      # debug "running #{cmd} #{massaged_args(args).inspect}"
      
      pwrite, pread, perror, pexception = IO.pipe, IO.pipe, IO.pipe, IO.pipe

      verbose = $VERBOSE
      begin
        $VERBOSE = nil
        pexception.last.fcntl(Fcntl::F_SETFD, Fcntl::FD_CLOEXEC)

        cid = fork {
          pwrite.last.close
          STDIN.reopen pwrite.first
          pwrite.first.close

          pread.first.close
          STDOUT.reopen pread.last
          pread.last.close

          perror.first.close
          STDERR.reopen perror.last
          perror.last.close

          STDOUT.sync = STDERR.sync = true

          if args[:group]
            Process.egid = args[:group]
            Process.gid = args[:group]
          end

          if args[:user]
            Process.euid = args[:user]
            Process.uid = args[:user]
          end

          # Copy the specified environment across to the child's environment.
          # Keys with `nil` values are deleted from the environment.
          args[:environment].each do |key,value|
            if value.nil?
              ENV.delete(key.to_s)
            else
              ENV[key.to_s] = value
            end
          end

          if args[:umask]
            umask = ((args[:umask].respond_to?(:oct) ? args[:umask].oct : args[:umask].to_i) & 007777)
            File.umask(umask)
          end

          if args[:cwd]
            Dir.chdir args[:cwd]
          end
          
          begin
            if cmd.kind_of?(Array)
              exec(*cmd)
            else
              exec(cmd)
            end
            raise 'forty-two' 
          rescue Exception => e
            Marshal.dump(e, pexception.last)
            pexception.last.flush
          end
          pexception.last.close unless (pexception.last.closed?)
          exit!
        }
      ensure
        $VERBOSE = verbose
      end

      [pwrite.first, pread.last, perror.last, pexception.last].each{|fd| fd.close}

      begin
        e = Marshal.load pexception.first
        raise(Exception === e ? e : "unknown failure!")
      rescue EOFError # If we get an EOF error, then the exec was successful
        42
      ensure
        pexception.first.close
      end

      pwrite.last.sync = true

      pi = [pwrite.last, pread.first, perror.first]

      if b 
        begin
          if args[:stream]
            b[cid, *pi]
            ShellResult.new(Process.waitpid2(cid).last, args)
          else
            o = StringIO.new
            e = StringIO.new

            if args[:input]
              pi[0].puts args[:input]
            end

            pi[0].close
            
            stdout = pi[1]
            stderr = pi[2]

            stdout.sync = true
            stderr.sync = true

            stdout.fcntl(Fcntl::F_SETFL, pi[1].fcntl(Fcntl::F_GETFL) | Fcntl::O_NONBLOCK)
            stderr.fcntl(Fcntl::F_SETFL, pi[2].fcntl(Fcntl::F_GETFL) | Fcntl::O_NONBLOCK)
            
            stdout_finished = false
            stderr_finished = false
           
            results = nil

            while !stdout_finished || !stderr_finished
              begin
                channels_to_watch = []
                channels_to_watch << stdout if !stdout_finished
                channels_to_watch << stderr if !stderr_finished
                ready = IO.select(channels_to_watch, nil, nil, 1.0)
              rescue Errno::EAGAIN
                results = Process.waitpid2(cid, Process::WNOHANG)
                if results
                  stdout_finished = true
                  stderr_finished = true 
                end
              end

              if ready && ready.first.include?(stdout)
                line = results ? stdout.gets(nil) : stdout.gets
                if line
                  o.write(line)
                else
                  stdout_finished = true
                end
              end
              if ready && ready.first.include?(stderr)
                line = results ? stderr.gets(nil) : stderr.gets
                if line
                  e.write(line)
                else
                  stderr_finished = true
                end
              end
            end
            results = Process.waitpid2(cid).last unless results
            o.rewind
            e.rewind
            b[cid, pi[0], o, e]

            ShellResult.new(results, args)
          end
        ensure
          pi.each{|fd| fd.close unless fd.closed?}
        end
      else
        [cid, pw.last, pr.first, pe.first]
      end
    end

    def massaged_args args
      returning(args.dup) do |args_to_print|
        args_to_print[:environment] = e = args[:environment].dup

        %w{LC_ALL GEM_HOME GEM_PATH RUBYOPT BUNDLE_GEMFILE}.each {|env| e.delete(env)}

        args_to_print['cwd'] = args_to_print['cwd'].to_s if args_to_print['cwd']

        args_to_print.delete_if{|k,v| v.blank?}
      end
    end

  end
end

class String
  def sh(options={})
    CommonMob::Shell.new(self,options)
  end
end


