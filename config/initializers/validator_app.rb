require "data_validator"
require "fuseki_util"
require "open-uri"

include FusekiUtil

module ValidatorApp
  # Configuration for the application
  # (loaded once)

  # Check if the Fuseki server is running
  if !server_running?
    puts "Fuseki Server isn't running. Start it by using: rake validator:fuseki:init"
    exit
  end
 
  def self.config
    @config ||= YAML.load_file(File.join(Rails.root, "config", "config.yml"))[Rails.env]
  end

  # JSON-LD context used for formatting validated data converted into JSON-LD
  def self.jsonld_context
    @jsonld_context ||= {
      file: ValidatorApp.load_jsonld_context, 
      uri:  ValidatorApp.config["validator"]["jsonld_context_uri"] 
    }
  end

  # Instance of SPARQL validator used in controllers
  def self.instance
    config = ValidatorApp.config["validator"]
    base_url = "http://127.0.0.1:#{config["port"]}/#{config["dataset"]}/"
    @instance ||= ::DataValidator.new(
      :base_uri               => config["base_uri"],
      :namespace              => config["namespace"],
      :sparql_endpoint        => "#{base_url}sparql",
      :sparql_update_endpoint => "#{base_url}update", 
      :test_dir               => "#{Rails.root}/config/validation-rules"
    )
  end

  def self.load_jsonld_context
    JSON.parse(File.read(File.join(Rails.root, "config", "context.jsonld")))["@context"]
  end
end
