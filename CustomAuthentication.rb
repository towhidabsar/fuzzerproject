require 'rubygems'
require 'mechanize'

#to a given product. For this product, BodgeIt and DVWA are two 
#applications you must authenticate to. These can be hardcoded. You 
#are welcome to add other customizations for other products to test
# your fuzzer further (e.g. your senior project). With custom 
# authentication turned off, the fuzzer should just crawl the exterior
#  of the webapp (perhaps get lucky if the vector list had a password)
class CustomAuthentication

=begin
	siteInfo = {
		"dvwa": ["admin", "password"],
		"bodgeit": "admin", "password"]
	}
=end

	username = "admin"
	password = "password"

	def self.authenticate(page, site)
		
	end
end