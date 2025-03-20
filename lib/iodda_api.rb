require 'httparty'

module IoddaApi
	class Client
	  include HTTParty
	  
	  # To create IoddaApi::Client.new, you need to provide the following arguments :
	  # * env (optional): either 'test', 'valid' or 'prod', will call the right environment for Iodda. Defaults to 'valid'
	  # * api_key (required): must be a Iodda Subscriber Api Key retreived in your Iodda Subcription
	  #   (available in the backend) or provided by the Iodda team
	  #   Api keys differ from one environment to the other
	  # * base_path (optional): provides the path to the api, defaults to the correct path for Subscriber Api v1
	  # * debug_mode (optional): if set to true, will output the connection info to the console while making requests. Defaults to false.
	  def initialize(env: 'valid', api_key: nil, base_path: nil, debug_mode: false)
		@base_uri = case env
			when 'test' # only works with a VPN to access the domain
				'https://iodda.spw.test.wallonie.be'
			when 'valid'
				'https://iodda.spw.valid.wallonie.be'
			when 'prod'
				'https://iodda.be'
			end	
		@api_key = 		api_key || 		Rails.application.credentials.iodda[env]
		@base_path = 	base_path || 	'/subscriber/api/v1/'
		@debug_config = debug_mode ? {debug_output: STDOUT} : {}
	  end	
	  
	private
	  
	  def build_request_headers
		{"User-Agent" => "Httparty",
		"IODDA-SUBSCRIPTION-APIKEY" => @api_key }
	  end
	  
	  def build_url(call, languages:['FR'], options:{})
		parameters = options.map do |key,value|
			"#{key}=#{value}"
			end << "lang=#{languages.join(',')}"
		"#{@base_uri}#{@base_path}#{call}?#{parameters.join('&')}"
	  end
	  
	  def send_request(url,request_options)
		options = {headers: build_request_headers}.merge(@debug_config).merge(request_options)
		puts "Fetching #{url} ..."
		response = self.class.get(url, options)
	  end
	
	public

	  def procedures(taxonomy_ids=[], page=1, page_size=100, languages:['FR'], request_options:{})
		url = build_url('procedures', 
						languages:languages,
						options:{'taxonomyId':taxonomy_ids.join(','),
								 'page':page,
								 'pageSize':page_size})
		response = send_request(url,request_options)
		#response['items'].first
	  end
	  
	  def procedures_details(procedure_id, languages:['FR'], request_options:{})
		url = build_url('proceduresDetails', 
						languages:languages,
						options:{'procedureId':procedure_id})
		response = send_request(url,request_options)
		response['items'].first
	  end
	  
	  def taxonomies(taxonomy_type_id, languages:['FR'], request_options:{})
		url = build_url('taxonomies', 
						languages:languages,
						options:{'taxonomyTypeId':taxonomy_type_id})
		response = send_request(url,request_options)
		response['items']
	  end
	  
	  def administrations(languages:['FR'], request_options:{})
		url = build_url('administrations', 
						languages:languages)
		response = send_request(url,request_options)
		response['items']
	  end
	  
	  def administrations_details(administration_id, languages:['FR'], request_options:{})
		url = build_url('administrationsDetails', 
						languages:languages,
						options:{'administrationId':administration_id})
		response = send_request(url,request_options)
		response['items'].first
	  end
	  
	  # https://iodda.spw.valid.wallonie.be/subscriber/api/v1/modifiedProcedures?lang=FR&modifiedOnOrAfter=2022-04-24T11%3A26%3A00%2B02%3A00&page=3
	  def modified_procedures(modified_on_or_after, languages:['FR'], request_options:{})
	    url = build_url('modifiedProcedures', 
						languages:languages,
						options:{'modifiedOnOrAfter':modified_on_or_after.to_fs(:iso8601)})
		response = send_request(url,request_options)
	  end
	  
	end
end
