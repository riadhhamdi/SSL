#!/usr/bin/env ruby
require 'httpclient'
require 'base64'
require 'json'
require 'uri'


#####################################################
##   Connection  Parameters 
####################################################
#
@username = 'xxxxxxx'
@password = 'xxxxxx'
@satellite_hostname = 'xxxxxx'






@debug = false 
def loginfo(message)

puts " [Log]:[Info] #{message} " if @debug
 
end 

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
  result = rest_send(:get, url)['results']
  return result 
end 

def get_host_ids(url)
  host_ids = [] 
  host_list = get_host_list(url)
  loginfo(" Number of Hosts: #{host_list.length}")
  host_list.each_with_index do |host,index|
  host_ids[index] =  host['id']
  end  

  result = host_ids
  loginfo("All Host IDs: #{result}")
  return result 
end 

def get_host_report(host_id)
  url= "#{@base_uri}/hosts/#{host_id}"
  result = rest_send(:get, url)
end 







#########################################
##   Minimal report 
#########################################
def generate_minimal_report()

url="#{@base_uri}/hosts?per_page=1000"
host_ids = get_host_ids(url)
loginfo("Got those IDs: #{host_ids}")
### getting all hosts reports index
@full_report = []
host_ids.each_with_index do |item,index|
@full_report[index] = get_host_report(item)
end 

@full_report.each do |item|
puts '--------------------------------------'
puts "Host Details for #{item['name'] || 'Unknown'}" 
puts '--------------------------------------'
  begin 
   puts "IP ADDRESS: #{item['ip'] || 'nil' }"
   puts "ARCHITECTURE: #{item['architecture_name']  || 'Unknown' }"
   puts "OS:  #{item['operatingsystem_name']  || 'Unknown' }"
   puts "ENVIRONMENT: #{item['content_facet_attributes']['lifecycle_environment_name'] || 'Unkown'}"
   puts "KATELLO_INSTALLED: #{item['content_facet_attributes']['katello_agent_installed'] || 'false'}"
   puts "SEC ERRATA TO APPLY:  #{item['content_facet_attributes']['errata_counts']['security'] || 'nil'}"
 # puts "BUG ERRATA TO APPLY:  #{item['content_facet_attributes']['errata_counts']['bugfix'] || 'nil'}"

  rescue
   puts "Unable to retrieve information please check the Satellite Interface"
  end 
end 
end 
### main code ###
@authtoken = @username+":"+@password
@authtoken = Base64.strict_encode64(@authtoken)
@base_uri= "https://#{@satellite_hostname}/api/v2"

### getting host ids

   
generate_minimal_report() 

