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

	def initialize (opts = {})
		@agent = Mechanize.new{|a| a.ssl_version, 
			a.verify_mode = 'SSLv3', OpenSSL::SSL::VERIFY_NONE}
		@curPage 
		@foundLinks = Array.new
		@linkQueries = Hash.new		# Not sure to rename
		@formInputs = Hash.new		# Rename to foundInputs
		@cookies = Array.new		# Rename to cookies
		@speed

	end

	def authenticate

	end

	def crawl()	# take in input

	end

	def test

	end
end

