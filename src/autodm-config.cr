require "./config"

puts "AutoDisplayManager Configurator v. 0.1.2-cr (C) 2017 by Phitherek_"
puts
homepath = ENV["HOME"]
config = AutoDisplayManagerCR::Config.new("#{homepath}/.auto-display-manager")
if ARGV.size >= 1
    if %w(usage help list set unset switch next_profile remove).includes?(ARGV[0].downcase)
        profile = nil
    elsif ARGV.size >= 2
      profile = ARGV.delete_at(0).downcase 
    else
        puts "Usage: #{$0} [profile_name] <command> [parameters]"
        puts "See 'help' command for list of commands and parameters"
        abort(nil, 0)
    end
    if ARGV[0].downcase == "usage"
        puts "Usage: #{$0} [profile_name] <command> [parameters]"
        puts "See 'help' command for list of commands and parameters"
        abort(nil, 0)
    elsif ARGV[0].downcase == "help"
        puts "Usage: #{$0} [profile_name] <command> [parameters]"
        puts
        puts "Available commands: "
        puts
        puts "  * help - display this help message"
        puts "  * usage - display the usage line"
        puts "  * list - list the current configuration"
        puts "  * set - set a display definition. Usage: set <name> <string> [xrandr_parameters]"
        puts "  * unset - unset a display definition. Usage: unset <name>"
        puts "  * switch - switch to a profile defined in profile_name"
        puts "  * next_profile - switch to next profile in profile list"
        puts "  * remove - remove a profile defined in profile name"
        puts
        puts "Profile name is used only by list, set and unset commands. When profile name is not given, 'default' is assumed."
        puts
        abort(nil, 0)
    elsif ARGV[0].downcase == "list"
        puts "Current configuration: "
        config.display(profile)
    elsif ARGV[0].downcase == "set"
        if ARGV.size < 3
            puts "Usage: #{$0} [profile_name] set <name> <string> [xrandr_parameters]"
            puts "See 'help' command for full list of commands and parameters"
        else
            name = ARGV[1].downcase
            string = ARGV[2]
            params = ARGV[3..-1].join(" ")
            config.set_display(name, string, params, profile)
            config.save
            config.reset
            puts "Done!"
            puts "Current configuration: "
            config.display(nil)
        end
        abort(nil, 0)
    elsif ARGV[0].downcase == "unset"
        if ARGV.size < 2
            puts "Usage: #{$0} [profile_name] unset <name>"
            puts "See 'help' command for full list of commands and parameters"
        else
            name = ARGV[1].downcase
            config.remove_display(name,profile)
            config.save
            config.reset
            puts "Done!"
            puts "Current configuration: "
            config.display(nil)
        end
        abort(nil, 0)
    elsif ARGV[0].downcase == "switch"
        config.switch_profile(profile)
        config.save
        config.reset
        `/usr/bin/notify-send -t 3000 -a autodm-config -c autodm-config 'AutoDisplayManager profile switched\!' 'Switched to profile: #{config.selected_profile}'`
        puts "Done!"
        puts "Current configuration: "
        config.display(nil)
        abort(nil, 0)
    elsif ARGV[0].downcase == "next_profile"
        config.next_profile!
        config.save
        config.reset
        `/usr/bin/notify-send -t 3000 -a autodm-config -c autodm-config 'AutoDisplayManager profile switched\!' 'Switched to profile: #{config.selected_profile}'`
        puts "Done!"
        puts "Current configuration: "
        config.display(nil)
        abort(nil, 0)
    elsif ARGV[0].downcase == "remove"
        if profile.nil?
            puts "Profile to delete not given! See 'help' for usage details."
        else
            config.remove_profile(profile)
            config.save
            config.reset
            puts "Done!"
            puts "Current configuration: "
            config.display(nil)
        end
        abort(nil, 0)
    end
end
puts "Usage: #{$0} [profile_name] <command> [parameters]"
puts "See 'help' command for list of commands and parameters"
