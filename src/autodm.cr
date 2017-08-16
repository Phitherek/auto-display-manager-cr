require "./config"
require "./state"

puts "AutoDisplayManager v. 0.1.1-cr (C) 2017 by Phitherek_"
puts
if ARGV.size < 1
    puts "Usage: #{$0} <start|kill|status|pause|resume>"
else
    basepath = ENV["HOME"]
    basepath += "/.auto-display-manager"
    case ARGV[0].downcase
    when "start"
        puts "Starting AutoDisplayManager..."
        s = AutoDisplayManagerCR::State.new(basepath)
        s.run
        s.save
        pid = -1
        p = fork do
            basepath = ENV["HOME"]
            basepath += "/.auto-display-manager"
            s = AutoDisplayManagerCR::State.load_from(basepath)
            c = AutoDisplayManagerCR::Config.new(basepath)
            profile = c.selected_profile
            profile ||= "default"
            displays = c.get_profile(profile).keys
            displays.each do |d|
                if d != "main"
                    system("xrandr --output #{c.get_display(d, profile)["str"]} --off")
                    s.set(d, "disconnected")
                end
            end
            s.set("main", "connected") if c.displays.includes?("main")
            s.save
            loop do
                s.reset
                c.reset
                if s.process == "running"
                    old_profile = profile
                    profile = c.selected_profile
                    profile ||= "default"
                    if old_profile != profile
                        c.displays.each do |d|
                            if d != "main"
                                if c.get_profile(old_profile).has_key?(d)
                                    system("xrandr --output #{c.get_display(d, old_profile)["str"]} --off")
                                    s.set(d, "disconnected")
                                end
                            end
                        end
                    end
                    displays = c.get_profile(profile).keys
                    displays.each do |d|
                        statestr = ""
                        displaystr = c.get_display(d, profile)["str"]
                        Process.run("xrandr | grep '\\b#{displaystr}\\b'", shell: true) do |p|
                            statestr = p.output.gets_to_end
                        end
                        if statestr[displaystr.size+1..displaystr.size+9] == "connected"
                            if s.get(d) == "disconnected"
                                system("xrandr --output #{displaystr} #{c.get_display(d, profile)["options"]}")
                            end
                            s.set(d, "connected")
                        elsif statestr[displaystr.size+1..displaystr.size+9] == "disconnec"
                            if s.get(d) == "connected"
                                system("xrandr --output #{displaystr} --off")
                            end
                            s.set(d, "disconnected")
                        end
                    end
                    s.save
                end
                sleep 5
            end
        end
        pid = p.pid
        pidpath = basepath + "/autodm.pid"
        File.open(pidpath, "w") do |f|
            f << pid.to_s
        end
        puts "AutoDisplayManager started!"
    when "kill"
        pid = -1
        pidpath = basepath + "/autodm.pid"
        if File.exists?(pidpath)
            File.open(pidpath, "r") do |f|
                pid = f.gets
                if pid.nil?
                    pid = -1
                else
                    pid = pid.to_i
                end
            end
        else
            puts "AutoDisplayManager is not running!"
        end
        if pid == -1
            puts "Pid file error!"
        else
            s = AutoDisplayManagerCR::State.load_from(basepath)
            s.kill
            Process.kill(Signal::TERM, pid)
            puts "AutoDisplayManager killed!"
        end
    when "status"
        s = AutoDisplayManagerCR::State.load_from(basepath)
        state = s.process.to_s
        puts "AutoDisplayManager is #{state}"
    when "pause"
        s = AutoDisplayManagerCR::State.load_from(basepath)
        s.pause
        s.save
        puts "AutoDisplayManager paused!"
    when "resume"
        s = AutoDisplayManagerCR::State.load_from(basepath)
        s.run
        s.save
        puts "AutoDisplayManager resumed!"
    else
        puts "Usage: #{$0} <start|kill|status|pause|resume>"
    end
end
