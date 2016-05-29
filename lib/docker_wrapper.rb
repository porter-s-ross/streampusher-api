require 'docker'
require 'socket'

class DockerWrapper
  attr_reader :container

  def initialize container
    @container = container
  end

  def self.find_or_create image, name, env=[], links=[], binds=[]
    begin
    container = Docker::Container.get name
    container.stop
    container.remove
    rescue Docker::Error::NotFoundError
      # container doesn't exist, so take no action
    end
    begin
      container = Docker::Container.create('Image' => image, 'name' => name, 'Env' => env, 'HostConfig' => host_config(links, binds))
    rescue Docker::Error::NotFoundError
      # image is not pulled yet
      Docker::Image.create('fromImage' => image)
      container = Docker::Container.create('Image' => image, 'name' => name, 'Env' => env, 'HostConfig' => host_config(links, binds))
    end
    self.new container
  end

  def start
    @container.start
  end

  def stop
    @container.stop
  end

  def host_port port
    # nice api docker heheh :P
    ports = @container.json["NetworkSettings"].fetch("Ports")
    if ports
      ports.fetch("#{port}/tcp").try(:first).fetch("HostPort")
    end
  end

  def env
    @container.json["Config"]["Env"]
  end

  def links
    @container.json["HostConfig"]["Links"]
  end

  def id
    @container.id
  end

  private

  def self.host_config links, binds
    {
      'Links' => links,
      'Binds' => binds,
      'ExtraHosts' => ["docker:#{local_private_ip}"],
      "PublishAllPorts" => true,
      "NetworkMode" => network_mode
    }
  end

  def self.network_mode
    "streampusher_default"
  end

  def self.local_private_ip
    # probably portable?
    Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
  end
end
