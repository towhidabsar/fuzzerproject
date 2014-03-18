require 'mechanize'
require 'rubygems'
require 'uri'

# Discovers all the inputs in the page
module InputDiscovery

	# Parses the given url to find possible input queries
	# Params:
	# +page+:: The +Page+ which to crawl for queries
	# +linkQueries+:: +Hash+ object of [link, queries]
	# Return: Updated +linkInputs+ with queries from the given +page+
	def discoverQueries(page)
		
		# All the queries from the given page
		pageQueries = page.uri.query

		# The uri of the page
		uri = page.uri # i.e. 'localhost/a/efefefwfqwe'

		# Check to see if given host is in the hash map
		if not linkQueries.has_key? uri
			linkQueries[uri] = Array.new
		end

		if not pageQueries == nil
			pageQueries = pageQueries.split("&")
			# Traverse each query in pageQueries & append to it's array
			pageQueries.each do |query|
				linkQueries[uri] << query
			end
		end
		return linkQueries
	end 

	# Parses the given list of forms & add them to the given hash map
	# Params:
	# +page+:: Acquires the forms and +URI+
	# +formInputs+:: +Hash+ object of [link, queries]
	# Return: Updated +formInputs+ with forms from the given +page+
	def discoverForms(page)

		# Get all the input forms in the page.
		pageForms = page.forms

		# The uri of the page
		uri = page.uri # i.e. 'localhost/a/efefefwfqwe'

		# Check to see if given host is in the hash map
		if not formInputs.has_key? uri
			formInputs[uri] = Array.new
		end
		
		# Traverse each form in pageForms & add it to it's array
		@pageForms.each do |form|
			formInputs[uri].concat(form.fields)
			formInputs[uri].concat(form.buttons)
		end
		
		return formInputs
	end

	# Acquires the browsers cookies via the given +agent+ & adds it to
	# 	the given array
	# Params:
	# +agent+:: 
	# Return: Updated +cookieInputs+ with cookies from the browser
	def discoverCookies
		@cookies << agent.cookies
	end
end