=begin
	CustomAuthentication
	PageDiscovery
		LinkDiscovery
		PageGuessing
	InputDiscovery
		ParseURLS
		FormParameters
		Cookies
	LackOfSanization
	SensitiveDataLeaked
	DelayedResponse


	Options
		--custom-auth=string

		Discover options:
			--common-words=file

		Test options:
			--vectors=file
			--sensitive=file
			--random=[true|false]
			--slow=500

	####################################

	(c) Crawler
		(v) agent
		(v) foundLinks
		(v) foundQueries
		(v) foundForms
		(v) foundCookies

		(f) Custom Authenticate

		(m) DiscoverPages
			(f) discoverPages
			(f) guessPages
			(f) filterOffSiteLinks

		(m) DiscoverInputs
			(f) discoverQueries
			(f) discoverForms
			(f) discoverCookies
			(f) filterRedundantInput

		(m) Test


		(m) DisplayResults
			(f) displayPages
			(f) displayQueries
			(f) displayForms
			(f) displayCookies
=end

require 'rubygems'
require 'mechanize'

class Crawler
	include DiscoverPages
	include DiscoverInputs
	include Test
	include DiplayResults	

	def initialize
		@agent = Mechanize.new{|a| a.ssl_version, 
			a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
		@curPage = nil 
		@host = nil
		# List of links found that will be traversed 
		@foundLinks = Array.new
		@visitedLists = Array.new
		@linkQueries = Hash.new		# Not sure to rename
		@formInputs = Hash.new		# Rename to foundInputs
		@cookies = Array.new		# Rename to cookies
		@speed


	end

	def authenticate url
		@agent.add_auth(http://127.0.0.1/dvwa, , )
	end..

	def crawl(link, opts = {})	# take in input
		@curPage = @agent.get(link)
		@host = curPage.uri.host
		
		puts "\n\tCrawling <#{link}>\n"

		discoverPages(link)

		
		@@finalResultSanitization = Array.new
		@@finalResultSensitive = Array.new
		@@finalResultSanitization[0] = "Lack of Sanitization In:"
		@@finalResultSensitive[0] = "Sensitive Data Found In:"
		
		# Get all the pages in the website.
		discoverPages(mainURL)
		
		# Traverse each of the pages and find all the possible inputs.
		foundLinks.each do |link|
			# Get the current page for the link
			@curPage = agent.get(link)
			
			# Get all the queries in the link
			discoverQueries(curPage)
			
			# Get all the input forms in the page
			discoverForms(curPage)
		end
		
		cookies = discoverCookies(agent)
		
		return [foundLinks, linkQueries, formInputs, cookies] 

	end

	def test

	end
end

