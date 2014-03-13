require 'mechanize'
require 'rubygems'
require 'uri'
require_relative 'inputValidation'
require_relative 'inputDiscovery'
require_relative 'customAuthentication'
require_relative 'displayResults'
require_relative 'pageDiscovery'

class FuzzOptions

	def self.fuzzDiscover( agent, mainURL)
	
		#Initialize the required variables
		linkQueries = Hash.new
		formInputs = Hash.new
		cookies = Array.new
		foundLinks = Array.new
		
		#Get all the pages in the website.
		foundLinks = PageDiscovery.pageDiscover( agent, mainURL )
		
		#Traverse each of the pages and find all the possible inputs.
		foundLinks.each do |link|
			#Get the current page for the link
			curPage = agent.get(link)
			#Get the host of the link i.e. localhost/a 
			curHost = curPage.uri.host
			#Get all the input forms in the page.
			pageForms = curPage.forms
			
			#Get all the queries in the link
			linkQueries = InputDiscovery.discoverQueries(curPage, linkQueries)
			
			#Get all the input forms in the page
			formInputs = InputDiscovery.discoverForms(pageForms, curHost, formInputs)
		end
		
		cookies = InputDiscovery.discoverCookies(agent, cookies)
		
		return [ foundLinks, linkQueries, formInputs, cookies ] 
	end


end
