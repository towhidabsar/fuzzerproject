require 'mechanize'
require 'rubygems'
require 'uri'

class DisplayResults

	# Creates the arrays that are needed to hold the links
	def self.displayInputs(links)
		puts "\n##########################################################################"
		puts "\tInputs via Links:"
		puts "##########################################################################"
		links.each do |key, value|
			puts "Base URL : #{key}"
			puts "Possible Inputs:"
			value.each do |input|
				puts input
			end
		end
	end

  # 
	def self.displayForms(forms)
		puts "\n##########################################################################"
		puts "\tInputs via Forms:"
		puts "##########################################################################"
		forms.each do |key, value|
			puts "Page URL: #{key.to_s}"
			value.each do |input|
				puts "\t Name: %s - Value: %s \t\tType: %s" %[input.name, input.value, input.type]
			end
		end
	end

  # 
	def self.displayCookies(cookies)
		puts "\n##########################################################################"
		puts "\tInputs via Cookies:"
		puts "##########################################################################"
		
		cookies.each do |cookie|
			puts "Name: %s \tDomain Name: %s \tValue = %s" %[cookie.name, cookie.domain, cookie.value]
		end
	end

	def self.displayTestResults()

	end
end