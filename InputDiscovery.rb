#Discovers all the inputs in the page.
require 'mechanize'
require 'rubygems'
require 'uri'
class InputDiscovery
	def self.linkInputDiscover(page, linkInputs)
		#Get the URL of the current page.
		url = page.link.uri
		url = url.to_s
		url = url.split('?')
		puts "AA"
		link = url[0]
		puts link
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
		url = page.link.uri
		if not formInputs.has_key? url
			formInputs[url] = Array.new
		end
		
		inputForms.each do |form|
			formInputs[url] << form
		end
		
		return formInputs
	end


	def self.cookieInputDiscover(page, cookieInputs)


	end
end