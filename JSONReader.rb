require 'rubygems'
require 'json'
require 'pp'

class JSONReader 
  #define instance variables
  attr_accessor :source_dir, :dest_dir
  
  def initialize()
    json = File.read('properties.json')
    config = JSON.parse(json)

    @source_dir = config["Quellordner"]
    @dest_dir = config["Zielordner"]
  end

  def getSourceDir()
    source_dir
  end

  def getDestDir()
    dest_dir
  end
end
