require "yaml"
require "file_utils"

module AutoDisplayManagerCR
    class State
        def initialize(path : String, destroy_old = true)
            FileUtils.mkdir_p(path)
            @filepath = "#{path}/state.yml"
            if File.exists?(@filepath) && destroy_old
                FileUtils.rm(@filepath)
            end
            @state = {} of String => String
        end

        def self.load_from(path : String)
            s = State.new(path, false)
            s.reset
            s
        end

        def set(name, state)
            unless ["connected", "disconnected"].includes?(state)
                state = "disconnected"
            end
            @state[name] = state
        end

        def run
            @state["process"] = "running"
        end

        def pause
            @state["process"] = "paused"
        end

        def kill
            FileUtils.rm(@filepath)
        end

        def save
            @state["last_update"] = Time.now.to_s
            File.open(@filepath, "w") do |f|
                f << YAML.dump(@state)
            end
        end

        def reset
            if File.exists?(@filepath)
                @state = from_yaml(YAML.parse(File.read(@filepath)))
            end
            @state ||= {} of String => String
        end

        def process
            if @state.has_key?("process")
                @state["process"]
            else
                "not running"
            end
        end

        def last_update
            if @state.has_key?("last_update")
                @state["last_update"]
            else
                Time.now.to_s
            end
        end

        def get(name : String)
            @state[name]
        end
        
        private def from_yaml(yaml_root : YAML::Any)
            ret = {} of String => String
            if yaml_root.raw.is_a?(Hash)
                yaml_root.each do |k, v|
                    ret[desym_yaml_string(k.as_s)] = desym_yaml_string(v.as_s)
                end
            end
            ret
        end

        private def desym_yaml_string(str : String)
            if str[0] == ':'
                str = str[1..-1]
            end
            str
        end
    end
end
