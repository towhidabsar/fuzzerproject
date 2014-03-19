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
		# List of links found that will be traversed 
		@foundLinks = [@curPage.uri]
		@linkQueries = Hash.new
		@formInputs = Hash.new		
		@cookies = Array.new	

		@options = options
		@link = link
	end

	#
	def authenticate link, customAuth, agent
		page = agent.get(link)
		case customAuth
			when "dvwa"
				username = "admin"
				authHelper(username, "password", @agent, page)
			when "bodgeit"
				newPage = agent.click(page.link_with(:text => /Login/))	
				username = "test@thebodgeitstore.com"
				authHelper(username, "password", @agent, newPage)
		end
	end

	def authHelper usr, pw, agent, page
		login_form = page.forms.first
		login_form.username = username
		login_form.password = pw
		agent.submit(login_form, login_form.buttons.first)
	end

	#
	def crawl test
		puts "\tCrawling <#{@link}>\n"

		if(@options[:customAuth] != nil || @options[:customAuth] != '')
			authenticate(@curPage.uri, @options[:customAuth])
		end

		# Get all the pages in the website.
		PageDiscovery.discoverPages(@agent, @foundLinks)
		
		# Traverse each of the pages and find all the possible inputs.
		@foundLinks.each do |link|
			# Get the current page for the link
			@curPage = @agent.get(link)
			
			# Get all the queries in the link
			@linkQueries = InputDiscovery.discoverQueries(@curPage, @linkQueries)
			
			# Get all the input forms in the page
			@formInputs = InputDiscovery.discoverForms(@curPage, @formInputs)
		end
		
		@cookies = InputDiscovery.discoverCookies(@agent)
		
		if(test)
			fuzzer = Fuzzer.new(@agent, @linkQueries, @formInputs, @cookies, @options)
			fuzzer.fuzz(@link)
		else
			ResultsOutput.printQueries(@linkQueries)
			ResultsOutput.printForms(@formInputs)
			ResultsOutput.printCookies(@cookies)
		end
	end
end