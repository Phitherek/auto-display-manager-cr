require "yaml"
require "file_utils"

module AutoDisplayManagerCR
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
        unless["connected", "disconnected"].include?(state)
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
        @state["last_update"] = Time.now
        File.open(@filepath, "w") do |f|
            f << YAML.dump(@state)
        end
    end

    def reset
        if File.exists?(@filepath)
            @state = YAML.parse(File.read(@filepath))
        end
        @state ||= {} of String => String
    end

    def process
        @state["process"]
    end

    def last_update
        @state["last_update"]
    end

    def get(name : String)
        @state[name]
    end
end
