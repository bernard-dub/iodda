# IODDA API CLient Example


 To create IoddaApi::Client.new, you need to provide the following arguments :
  * env (optional): either 'test', 'valid' or 'prod', will call the right environment for Iodda. Defaults to 'valid'
  * api_key (required): must be a Iodda Subscriber Api Key retreived in your Iodda Subcription (available in the backend) or provided by the Iodda team. The Api keys differ from one environment to the other
  * base_path (optional): provides the path to the api, defaults to the correct path for Subscriber Api v1
  * debug_mode (optional): if set, the console provides verbose feedback from the HTTParty gem. 

Examples :

iodda = IoddaApi::Client.new(api_key:'abdcefg-12345678')
iodda.taxonomies(3)
iodda.procedures
iodda.procedures_details(1931)
iodda.administrations
iodda.administrations_details(2342)
