require "yaml"
require "file_utils"

module AutoDisplayManagerCR
    class Config
        def initialize(path : String)
            FileUtils.mkdir_p(path)
            @filepath = "#{path}/config.yml"
            config = {} of String => (String|Array(String)|Hash(String, String|Hash(String, String))) 
            if File.exists?(@filepath)
                config = from_yaml(YAML.parse(File.read(@filepath)))
            end
            config["displays"] ||= [] of String
            config["profiles"] ||= [] of String
            @config = config.as(Hash(String, (String|Array(String)|Hash(String, String|Hash(String, String))))) 
        end

        def set_display(name : String, string : String, options : String, profile = "default")
            profile = profile.to_s
            config = @config 
            config[profile] ||= {} of String => (String|Hash(String, String))
            profile_data = config[profile]
            if profile_data.is_a?(Hash)
                profile_data[name] ||= {} of String => String
                display_data = profile_data[name]
                if display_data.is_a?(Hash)
                    display_data["str"] = string
                    display_data["options"] = options
                    profile_data[name] = display_data
                end
            end
            config[profile] = profile_data
            displays = config["displays"]
            if displays.is_a?(Array)
                displays << name
                displays.uniq!
            end
            config["displays"] = displays
            profiles = config["profiles"]
            if profiles.is_a?(Array)
                profiles << profile
                profiles.uniq!
            end
            config["profiles"] = profiles
            @config = config
        end

        def switch_profile(profile = "default")
            profile = profile.to_s
            @config["selected_profile"] = profile if @config["profiles"].includes?(profile)
        end

        def next_profile!
            sorted_profiles = @config["profiles"]
            if sorted_profiles.is_a?(Array)
                sorted_profiles.sort
                if @config.has_key?("selected_profile")
                    current_idx = sorted_profiles.index(@config["selected_profile"])
                    current_idx ||= -1
                    current_idx = current_idx + 1
                    current_idx = 0 if current_idx >= sorted_profiles.size
                else
                    current_idx = 0
                end
                @config["selected_profile"] = sorted_profiles[current_idx]
            end
        end

        def remove_profile(profile : String)
            profiles = @config["profiles"]
            if profiles.is_a?(Array)
                if profiles.includes?(profile)
                    @config.delete(profile)
                    profiles.delete(profile)
                end
                displays = [] of String
                profiles.each do |profile|
                    profile_data = @config[profile]
                    if profile_data.is_a?(Hash)
                        profile_data.each_key do |k|
                            displays << k
                        end
                    end
                    @config[profile] = profile_data
                end
                displays.uniq!
                @config["displays"] = displays
            end
            @config["profiles"] = profiles
        end

        def remove_display(name : String, profile = "default")
            profile = profile.to_s
            profile_data = @config[profile]
            if profile_data.is_a?(Hash)
                @config[profile].delete(name)
                displays =  [] of String
                profiles = @config["profiles"]
                if displays.is_a?(Array) && profiles.is_a?(Array)
                    profiles.each do |profile|
                        profile_data.each_key do |k|
                            displays << k
                        end
                    end
                    displays.uniq!
                end
                @config["profiles"] = profiles
                @config["displays"] = displays
            end
            @config[profile] = profile_data
        end

        def save
            keys = [] of String
            @config.each_key do |k|
                keys << k
            end
            keys.delete("displays")
            keys.delete("profiles")
            keys.delete("selected_profile")
            displays = @config["displays"]
            if displays.is_a?(Array)
                displays.each do |d|
                    keys.delete(d)
                end
            end
            profiles = @config["profiles"]
            if profiles.is_a?(Array)
                profiles.each do |p|
                    keys.delete(p)
                end
            end
            keys.each do |k|
                @config.delete(k)
                if profiles.is_a?(Array)
                    profiles.each do |p|
                        profile_data = @config[p]
                        if profile_data.is_a?(Array)
                            profile_data.delete(k)
                        end
                        @config[p] = profile_data
                    end
                end
            end
            File.open(@filepath, "w") do |f|
                f << YAML.dump(@config)
            end
        end

        def reset
            config = {} of String => (String|Array(String)|Hash(String, String|Hash(String, String))) 
            if File.exists?(@filepath)
                config = from_yaml(YAML.parse(File.read(@filepath)))
            end
            config["displays"] ||= [] of String
            config["profiles"] ||= [] of String
            displays = config["displays"]
            profiles = config["profiles"]
            if displays.is_a?(Array)
                if profiles.is_a?(Array)
                    profiles.each do |profile|
                        profile_data = config[profile]
                        if profile_data.is_a?(Hash)
                            profile_data.each_key do |k|
                                displays << k
                            end
                        end
                    end
                end
                displays.uniq!
            end
            config["displays"] = displays
            @config = config
        end

        def display(profile = nil.as(String|Nil))
            if profile != nil && profile != ""
                puts @config[profile].to_yaml
            else
                puts @config.to_yaml
            end
        end

        def profiles
            @config["profiles"].as(Array(String))
        end

        def displays
            @config["displays"].as(Array(String))
        end

        def selected_profile
            @config["selected_profile"].as(String)
        end

        def get_profile(profile = "default")
            @config[profile].as(Hash(String, String|Hash(String, String)))
        end

        def get_display(display : String, profile = "default")
            profile_data = @config[profile]
            if profile_data.is_a?(Hash)
                profile_data[display].as(Hash(String, String))
            else
                {} of String => String
            end
        end

        private def from_yaml(yaml_root : YAML::Any)
            ret = {} of String => (String|Array(String)|Hash(String, String|Hash(String, String))) 
            if yaml_root.raw.is_a?(Hash)
                yaml_root.each do |k, v|
                    if k.raw.is_a?(String)
                        if v.raw.is_a?(String)
                            ret[desym_yaml_string(k.as_s)] = desym_yaml_string(v.as_s)
                        elsif v.raw.is_a?(Array)
                            tmp = [] of String
                            v.each do |vv|
                                tmp << desym_yaml_string(vv.as_s)
                            end
                            ret[desym_yaml_string(k.as_s)] = tmp
                        elsif v.raw.is_a?(Hash)
                            profile_data = {} of String => String|Hash(String, String)
                            v.each do |vk, vv|
                                if vv.raw.is_a?(Hash)
                                    display_data = {} of String => String
                                    vv.each do |vvk, vvv|
                                        display_data[desym_yaml_string(vvk.as_s)] = desym_yaml_string(vvv.as_s)
                                    end
                                    profile_data[desym_yaml_string(vk.as_s)] = display_data
                                end
                            end
                            ret[desym_yaml_string(k.as_s)] = profile_data
                        end
                    end
                end
            end
            return ret                 
        end

        private def desym_yaml_string(str : String)
            if str[0] == ':'
                str = str[1..-1]
            end
            str
        end
    end
end
