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
	  
	  # Retrieves a summary of procedures corresponding to criterias passed in request parameters
	  # * taxonomy_ids : a single id or an array of ids of taxonomies such as targets, topics, etc. Use the taxonomies endpoint to get all available ids
	  # * page and page_size : pagination instructions. Use page_size=0 to retrieve everything at once (may be resource sensitive !)
	  # * languages : array of language codes passed as strings (FR, DE, EN, NL)
	  # * request_options : other options specific to HTTParty, if needed.
	  
	  def procedures(taxonomy_ids='', page=1, page_size=100, languages:['FR'], request_options:{})
		normalized_taxonomy_ids = taxonomy_ids.is_a?(Array) ? taxonomy_ids.join(',') : taxonomy_ids
		url = build_url('procedures', 
						languages:languages,
						options:{'taxonomyId':normalized_taxonomy_ids,
								 'page':page,
								 'pageSize':page_size})
		response = send_request(url,request_options)
		#response['items'].first
	  end
	  
	  # Retrieves a detailed view of one or more procedures whose ids are passed in parameters
	  # * procedure_ids : a single id or an array of ids of procedures
	  # * languages : array of language codes passed as strings (FR, DE, EN, NL)
	  # * request_options : other options specific to HTTParty, if needed.
	  
	  def procedures_details(procedure_ids, languages:['FR'], request_options:{})
		normalized_procedure_ids = procedure_ids.is_a?(Array) ? procedure_ids.join(',') : procedure_ids
		url = build_url('proceduresDetails', 
						languages:languages,
						options:{'procedureId':normalized_procedure_ids})
		response = send_request(url,request_options)
		response['items'].first
	  end
	  
	  # Retrieves a tree  view of of all elements of a taxonomy whose id is passed in parameters
	  # * taxonomy_type_id : a single id of a taxonomy type, among the following :
	  #	   * 1 = Procedure types
	  #	   * 2 = Topics
	  #	   * 3 = Targets
	  #	   * 4 = Keywords
	  #	   * 5 = Competencies
	  #	   * 6 = Competent entities
	  #	   * 8 = Life events
	  # * languages : array of language codes passed as strings (FR, DE, EN, NL)
	  # * request_options : other options specific to HTTParty, if needed.
	  
	  def taxonomies(taxonomy_type_ids, languages:['FR'], request_options:{})
		normalized_taxonomy_type_ids = taxonomy_type_ids.is_a?(Array) ? taxonomy_type_ids.join(',') : taxonomy_type_ids
		url = build_url('taxonomies', 
						languages:languages,
						options:{'taxonomyTypeId':normalized_taxonomy_type_ids})
		response = send_request(url,request_options)
		response['items']
	  end
	  
	  # Retrieves a tree of all the administrations associated to the subscription
	  # * languages : array of language codes passed as strings (FR, DE, EN, NL)
	  # * request_options : other options specific to HTTParty, if needed.
	  
	  def administrations(languages:['FR'], request_options:{})
		url = build_url('administrations', 
						languages:languages)
		response = send_request(url,request_options)
		response['items']
	  end
	  
	  # Retrieves a detailed view of a specific administration whose id is specified in parameters.
	  # * administration_id: id of an administration
	  # * languages : array of language codes passed as strings (FR, DE, EN, NL)
	  # * request_options : other options specific to HTTParty, if needed.
	  
	  def administrations_details(administration_id, languages:['FR'], request_options:{})
		url = build_url('administrationsDetails', 
						languages:languages,
						options:{'administrationId':administration_id})
		response = send_request(url,request_options)
		response['items'].first
	  end
	  
	  # Retrieves a list of mutations (informations that have been created, deleted or updated)
	  # since a datetime specified in parameters.
	  # * modified_on_or_after: a datetime (Time object)
	  # * languages : array of language codes passed as strings (FR, DE, EN, NL)
	  # * request_options : other options specific to HTTParty, if needed.
	  
	  def modified_procedures(modified_on_or_after, languages:['FR'], request_options:{})
	    url = build_url('modifiedProcedures', 
						languages:languages,
						options:{'modifiedOnOrAfter':modified_on_or_after.to_fs(:iso8601)})
		response = send_request(url,request_options)
	  end
	  
	end
end
