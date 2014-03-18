#
module CustomAuthentication
	def authenticate(link, customAuth)
		@agent.get(link) do |page|
			case customAuth
				when "dvwa"
					action = 'login.php'
					username = "admin"
				when "bodgeit"
					page = @agent.click(page.link_with(:text => /Login/))	
					action = '/login.jsp'
					username = "test@thebodgeitstore.com"
			end
			login_form = page.form_with(:action => action)
			login_form.username = username
			login_form.password = "password"
			@agent.submit(login_form, login_form.buttons.first)
		end
	end
end

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