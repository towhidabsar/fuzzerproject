# Discovers all the inputs in the page
module InputDiscovery

	# Parses the given url to find possible input queries
	# Params:
	# +page+:: The +Page+ which to crawl for queries
	# +linkQueries+:: +Hash+ object of [link, queries]
	# Return: Updated +linkInputs+ with queries from the given +page+
	def discoverQueries
		# All the queries from the given page
		pageQueries = page.uri.query

		# Check to see if given host is in the hash map
		if not @linkQueries.has_key? page.uri
			@linkQueries[page.uri] = Array.new
		end

		if not pageQueries == nil
			pageQueries = pageQueries.split("&")
			# Traverse each query in pageQueries & append to it's array
			pageQueries.each do |query|
				@linkQueries[page.uri] << query
			end
		end
	end 

	# Parses the given list of forms & add them to the given hash map
	# Params:
	# +page+:: Acquires the forms and +URI+
	# +formInputs+:: +Hash+ object of [link, queries]
	# Return: Updated +formInputs+ with forms from the given +page+
	def discoverForms
		# Check to see if given host is in the hash map
		if not @formInputs.has_key? page.uri
			@formInputs[page.uri] = Array.new
		end
		
		# Traverse each form in page.forms & add it to it's array
		page.forms.each do |form|
			@formInputs[page.uri].concat(form.fields)
			@formInputs[page.uri].concat(form.buttons)
		end
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