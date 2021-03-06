def colorize(code, string)
    $colors_supported = (ENV['TERM'] and (`tput colors`.to_i > 8)) unless defined? $colors_supported
    return string unless $colors_supported
    "\033[#{code}m#{string}\033[0m"
end

def out(cmd)
    puts colorize("33", "> #{cmd}")
end

def say(what)
    puts colorize("34", what)
end

def sys(cmd)
    out(cmd)
    $stdout.flush
    if not system(cmd) then
        puts colorize("31", "failed with code #{$?}")
        exit $?.exitstatus
    end
end

def sys!(cmd)
    out(cmd)
    $stdout.flush
    system(cmd)
end

def die(message, code=1)
    puts message
    exit code
end

def set_permanent_sysctl(name, value="1", path = "/etc/sysctl.conf")
    system("touch \"#{path}\"") unless File.exists? path
    lines = []
    r = Regexp.new(Regexp.escape(name))
    set = false
    replacement = "#{name}=#{value} \# added by asepsis.binaryage.com\n"
    File.open(path, "r") do |f|
        f.each do |line|
            if line =~ r then
               line = replacement
               set = true
            end
            lines << line
        end
    end
    lines << replacement unless set
    File.open(path, "w") do |f|
        f << lines.join
    end
end

def remove_permanent_sysctl(name, path = "/etc/sysctl.conf")
    return unless File.exists? path
    lines = []
    r = Regexp.new(Regexp.escape(name))
    File.open(path, "r") do |f|
        f.each do |line|
            if line =~ r then
                next
            end
            lines << line
        end
    end
    File.open(path, "w") do |f|
        f << lines.join
    end
end
