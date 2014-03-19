require 'mechanize'
require './pageDiscovery'
require './inputDiscovery'
require './resultsOutput'
require './fuzzer'

class Crawler
	include PageDiscovery
	include InputDiscovery
	include ResultsOutput

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

		puts options.inspect
		@options = options
		@link = link
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
	def crawl test
		puts "\n\tCrawling <#{@link}>\n"

		if(@options[:customAuth] != nil || @options[:customAuth] != '')
			authenticate(@link, @options[:customAuth])
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
		
		if(test)
			fuzzer = Fuzzer.new(@agent, @options, @cookies)
			fuzzer.fuzz
		else
			ResultsOutput.printQueries(linkQueries)
			ResultsOutput.printForms(formInputs)
			ResultsOutput.printCookies(cookies)
		end
	end
end