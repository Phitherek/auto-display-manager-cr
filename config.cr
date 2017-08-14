require "yaml"
require "file_utils"

module AutoDisplayManagerCR
    class Config
        def initialize(path : String)
            FileUtils.mkdir_p(path)
            @filepath = "#{path}/config.yml"
            if File.exists?(@filepath)
                @config = YAML.parse(File.read(@filepath))
            end
            @config ||= {} of String => (String|Array(String)|Hash(String, String|Hash(String, String)))
            @config["displays"] ||= [] of String
            @config["profiles"] ||= [] of String
        end

        def set_display(name : String, string : String, options : String, profile = "default")
            @config[profile] ||= {} of String => (String|Hash(String, String))
            @config[profile][name] ||= {} of String => String
            @config[profile][name]["str"] = string
            @config[profile][name]["options"] = options
            @config["displays"] << name
            @config["displays"].uniq!
            @config["profiles"] << profile
            @config["profiles"].uniq!
        end

        def switch_profile(profile = "default")
            @config["selected_profile"] = profile if @config["profiles"].includes?(profile)
        end

        def next_profile!
            sorted_profiles = @config["profiles"].sort
            current_idx = sorted_profiles.find_index(@config["selected_profile"])
            current_idx ||= -1
            current_idx = current_idx + 1
            current_idx = 0 if current_idx >= sorted_profiles.count
            @config["selected_profile"] = sorted_profiles[current_idx]
        end

        def remove_profile(profile : String)
            if @config["profiles"].include?(profile)
                @config.delete(profile)
                @config["profiles"].delete(profile)
            end
            @config["displays"] = [] of String
            @config["profiles"].each do |profile|
                @config[profile].each_key do |k|
                    @config["displays"] << k
                end
            end
            @config["displays"].uniq!
        end

        def remove_display(name : String, profile = "default")
            @config[profile].delete(name)
            @config["displays"] = [] of String
            @config["profiles"].each do |profile|
                @config[profile].each_key do |k|
                    @config["displays"] << k
                end
            end
            @config["displays"].uniq!
        end

        def save
            keys = [] of String
            @config.each_key do |k|
                keys << k
            end
            keys.delete("displays")
            keys.delete("profiles")
            keys.delete("selected_profile")
            @config["displays"].each do |d|
                keys.delete(d)
            end
            @config["profiles"].each do |p|
                keys.delete(p)
            end
            keys.each do |k|
                @config.delete(k)
                @config["profiles"].each do |p|
                    @config[p].delete(k)
                end
            end
            File.open(@filepath, "w") do |f|
                f << YAML.dump(@config)
            end
        end

        def reset
            if File.exists?(@filepath)
                @config = YAML.parse(File.read(@filepath))
            end
            @config ||= {} of String => (String|Array(String)|Hash(String, String|Hash(String, String)))
            @config["profiles"] ||= [] of String
            @config["displays"] ||= [] of String
            @config["profiles"].each do |profile|
                @config[profile].each_key do |k|
                    @config["displays"] << k
                end
            end
            @config["displays"].uniq!
        end

        def display(profile = nil.as(String|Nil))
            if profile != nil && profile != ""
                puts @config[profile].to_yaml
            else
                puts @config.to_yaml
            end
        end

        def profiles
            @config["profiles"]
        end

        def displays
            @config["displays"]
        end

        def selected_profile
            @config["selected_profile"]
        end

        def get_profile(profile = "default")
            @config[profile]
        end

        def get_display(display : String, profile = "default")
            @config[profile][display]
        end
    end
end
