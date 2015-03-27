#!/usr/bin/env ruby
require 'linode'
require 'open-uri'

api_key = 'your-api-key'

dynamic_domain = 'your-domain.org'
dynamic_host = 'hostname'

ip_service = open("http://some-service-returning-ip-address-as-text.com/")
dynamic_ip = ip_service.read

l = Linode.new(:api_key => api_key)

domain_id=""
l.domain.list.each do |domain|
  if domain.domain == dynamic_domain
    domain_id=domain.domainid.to_s
  end
end

unless domain_id.empty?
  resource_id=""
  l.domain.resource.list(:DomainId => domain_id).each do |resource|
    if resource.name == dynamic_host
      resource_id = resource.resourceid.to_s
      if resource.target == dynamic_ip
        puts 'IP not changed, doing nothing'
      else
        puts "Updating IP to #{dynamic_ip}"
        l.domain.resource.update(:DomainId => domain_id, :ResourceId => resource_id, :Target => dynamic_ip)
      end
    end
  end
  if resource_id.empty?
    # create
    l.domain.resource.create(:DomainId => domain_id, :Name => dynamic_host, :Target => dynamic_ip, :Type => 'A')
  end
end
