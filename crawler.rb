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

require 'mechanize'

class Crawler
	include DiscoverPages
	include DiscoverInputs
	include Test
	include ResultsOutput
	include CustomAuthentication

	def initialize options, link
		@agent = Mechanize.new{|a| a.ssl_version, 
			a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
		@curPage = @agent.get(link)
		@host = @curPage.uri.host
		# List of links found that will be traversed 
		@foundLinks = Array.new
		@linkQueries = Hash.new
		@formInputs = Hash.new		
		@cookies = Array.new	

		@options = options
	end

	#
	def authenticate link, customAuth
		case customAuth
			when "dvwa"
				page = agent.get(link)
				username = "admin"
			when "bodgeit"
				page = agent.click(agent.get(link).link_with(:text => /Login/))	
				username = "test@thebodgeitstore.com"
		end
		login_form = page.forms.first
		login_form.username = username
		login_form.password = "password"
		agent.submit(login_form, login_form.buttons.first)
	end

	#
	def crawl test?
		puts "\n\tCrawling <#{opts[:link]}>\n"
		
		if(opts[:customAuth])
			authenticate(opts[:customAuth])
		end

		# Get all the pages in the website.
		PageDiscovery.discoverPages(mainURL)
		
		# Traverse each of the pages and find all the possible inputs.
		foundLinks.each do |link|
			# Get the current page for the link
			@curPage = agent.get(link)
			
			# Get all the queries in the link
			InputDiscovery.discoverQueries
			
			# Get all the input forms in the page
			InputDiscovery.discoverForms
		end
		
		cookies = InputDiscovery.discoverCookies
		
		if(test?)
			fuzzer = Fuzzer.new(@agent, @options, @cookies)
			fuzzer.fuzz
		else
			ResultsOutput.printQueries(linkQueries)
			ResultsOutput.printForms(formInputs)
			ResultsOutput.printCookies(cookies)
		end
	end
end