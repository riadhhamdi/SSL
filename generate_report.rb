#!/usr/bin/env ruby
require 'httpclient'
require 'base64'
require 'json'
require 'uri'

def rest_send(http_verb,url)
#  loginfo(" --> Creds : #{@username}")
  http = HTTPClient.new
  http.ssl_config.verify_mode = OpenSSL::SSL::VERIFY_NONE

  #headers = { "Accept" => "application/json",
  #  "X-IPM-Username" => @username,
  #  "X-IPM-Password" => @password
  #  }
  headers = { "Accept" => "application/json",
    "Authorization" => "Basic #{@authtoken}"
    }
  
  case http_verb
    when :get
    result = JSON.parse(http.get(url, nil, headers).content)
    when :post
    result = JSON.parse(http.post(url, nil, headers).content)
    when :delete
    result = JSON.parse(http.delete(url, nil, headers).content)
    else
    loginfo("====> ERROR : Unknown http_verb in rest_send")
  end
 # comment / uncomment if needed (big output) 
 # loginfo("--> Request raw result : #{result}".green)
  result

end

def get_host_list(url)
  result = rest_send(:get, url)
end 
def get_host_ids(url)
  host_ids = [] 
  host_list = get_host_list(url)
  host_list['results'].each_with_index do |host,index|
  host_ids[index] =  host['id']
  end  

result = host_ids
end 
def get_host_report(host_id)
  url= "#{@base_uri}/hosts/#{host_id}"
  result = rest_send(:get, url)
end 
### main code ###
@username = 'admin'
@password = 'redhat'
@authtoken = @username+":"+@password
@authtoken = Base64.strict_encode64(@authtoken)
@base_uri= 'https://192.168.56.3/api/v2'
url="#{@base_uri}/hosts/4"
#result = rest_send(:get, url) 
#puts result

### getting host ids
url="#{@base_uri}/hosts"
host_ids = get_host_ids(url)
puts '************ host ids ************'
#puts host_ids

### getting all hosts reports index
@full_report = []
host_ids.each_with_index do |item,index|
 @full_report[index] = get_host_report(item)
end 
#puts @full_report
#puts 'hostname			environment			operating system			ip			katello_present '     
puts  "hostname     	 		 OS	Arch			Environment	   IP		katello_agent_installed     security_errata  bugfix_errata  "
@full_report.each do |item|
 if item['ip'] != '10.0.2.15'
 puts  "#{item['facts']['network::hostname'] || Unknown }   #{item['operatingsystem_name']  || 'Unknown' }	 #{item['architecture_name']  || 'Unknown' }			#{item['environment_name'] || 'nil'}                #{item['ip'] || 'nil' }			#{item['katello_agent_installed'] || 'N/A'}     		#{item['content_facet_attributes']['errata_counts']['security'] || 'nil'}  		#{item['content_facet_attributes']['errata_counts']['bugfix'] || 'nil'}  "
 end 
end  
