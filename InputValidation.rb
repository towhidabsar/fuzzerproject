def validateURL(input)
  #input = gets
  input = input.downcase.chomp
  if(input.include?('://'))
    input = input.split('://')
    address = input[1].split('/')
  else
    address  = input.split('/')
  end

  if(address.is_a? Array)
    domain = address[0]
  else
    domain = address
  end
  
  if(!domain.include?('.'))
    return false
  else
    domain = domain.split('.')
  end

  domainEnd = Array['com', 'net', 'org', 'gov', 'edu']

  final = Array.new

  if(input[0].eql?('http') || input[0].eql?('https'))
    final << (input[0] + '://')
  else
    final << 'https://'
  end

  if(domainEnd.include?(domain[domain.length - 1]))
    if(!domain[0].eql?('www'))
      final << 'www.'
    end
    domain.each_index do |index|
      if(index == (domain.length - 1))
	final << domain[index]
      else
        final << (domain[index] + '.')
      end
    end
  end
  
  if(address.is_a? Array)
    address = address[1..-1]
    address.each_index do |index|
      final << ('/' + address[index])
    end
  end
  return final.join
end
