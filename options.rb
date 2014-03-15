require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'inputValidation'
require_relative 'inputDiscovery'
require_relative 'customAuthentication'
require_relative 'displayResults'
require_relative 'pageDiscovery'

class Options

	def self.fuzzDiscover(agent, mainURL)
	
		#Initialize the required variables
		linkQueries = Hash.new
		formInputs = Hash.new
		
		# Get all the pages in the website.
		foundLinks = PageDiscovery.discoverPages(agent, mainURL)
		
		# Traverse each of the pages and find all the possible inputs.
		foundLinks.each do |link|
			# Get the current page for the link
			curPage = agent.get(link)
			
			# Get all the queries in the link
			linkQueries = InputDiscovery.discoverQueries(curPage, linkQueries)
			
			# Get all the input forms in the page
			formInputs = InputDiscovery.discoverForms(curPage, formInputs)
		end
		
		cookies = InputDiscovery.discoverCookies(agent)
		
		return [foundLinks, linkQueries, formInputs, cookies] 
	end
	
	def self.fuzzTest( agent, linkQueries, formInputs, cookies)
 
     curSecurity = ["low", "medium", "high"]
     i = 0
     #For dvwa change cookie value, start with low, medium and then high.
     cookies.each do |cookie|
     
       if cookie.name == "security"
         cookie.value = curSecurity[i]
       end
     
       linkQueries.each do |link, queries|
         agent.post( link, '>"><script>alert("XSS")</script>&"') 
         puts agent.page.uri
         
       end
     end
	end


end
