require "../spec_helper"
require "amber"

class HelloController < Amber::Controller::Base
  include OpenAPI::Generator::Controller

  @[OpenAPI(
    <<-YAML
      summary: Says hello
      responses:
        200:
          description: OK
    YAML
  )]
  def index
    "hello world"
  end
end

class Amber::Environment::Logging
  def initialize(initial_logging : OptionsType)
    logging = DEFAULTS.merge(initial_logging)
    @colorize = logging["colorize"].as(Bool)
    @color = logging["color"].as(String)
    # Replace severity assignment otherwise it prevents compilation…
    @severity = "debug"
    @filter = logging["filter"].as(Array(String))
    @skip = logging["skip"].as(Array(String))
  end
end

Amber::Server.configure do
  routes :api do
    get "/:id", HelloController, :index
  end
end

require "../../src/openapi-generator/providers/amber.cr"

describe OpenAPI::Generator::RoutesProvider::Amber do
  it "should correctly detect routes and map them with the controller method" do
    provider = OpenAPI::Generator::RoutesProvider::Amber.new
    route_mappings = provider.route_mappings
    route_mappings.should eq [
      {"get", "/{id}", "HelloController::index", ["id"]},
      {"head", "/{id}", "HelloController::index", ["id"]},
      {"options", "/{id}", "HelloController::index", ["id"]},
    ]
  end
end
