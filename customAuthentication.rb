require 'rubygems'
require 'mechanize'


class CustomAuthentication
	def self.authenticate(agent, link, customAuth)
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
end