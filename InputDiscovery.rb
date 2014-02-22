#Discovers all the inputs in the page.
require 'mechanize'
require 'rubygems'
require 'uri'

class InputDiscovery
	def self.linkInputDiscover(page, linkInputs)
		#Get the URL of the current page.
		url = page.uri
		url = url.to_s
		url = url.split('?')
		link = url[0]
		input = url[1]
		if not linkInputs.has_key? link
			linkInputs[link] = Array.new
		end
		if url.length > 1
			input = input.split('&')
			input.each do |x|
				linkInputs[link] << x
			end
		end
		
		return linkInputs
	end

	def self.formInputDiscover(page, formInputs)
		#Get all the form parameters of the page
		inputForms = page.forms
		url = page.uri

		#instantiate an array within the hash
		if not formInputs.has_key? url
			formInputs[url] = Array.new
		end
		
		#Append each form within the current page to the array
		inputForms.each do |forms|
			formInputs[url].concat(forms.fields)
			formInputs[url].concat(forms.buttons)
		end
		
		return formInputs
	end


	def self.cookieInputDiscover(agent, cookieInputs)
		cookies = agent.cookies
		cookieInputs = agent.cookies
		return cookieInputs
	end
end