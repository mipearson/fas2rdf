class ConvertController < ApplicationController
  def index
  end
  
  def convert
    headers['Location'] = 'valid.rdf'
    render :text => fas_to_rdf(params['convert']['fas_file']), :status => 200, :content_type => 'application/octet-stream'
  end
  
  private
  
  def fas_to_rdf src_file 
    sequences = 0

    sequence_name = ''
    sequence = ''

    lines = []

    src_file.read.split("\n").each do |line|
    	line.gsub!("\r", "")
    	if line.start_with?('>')
    		if sequence.length > 0
    			lines << ">#{sequence_name};1;;;;;;;"
    			if sequence.include?('1')
    				STDERR.puts "Warning: #{sequence_name} contains a 1, replacing with a -"
    				sequence.gsub!('1', '-')
    			end
    			lines << sequence
    #			lines << "#{sprintf "%10s", sequence_name}#{sequence}"
    	#		lines << "#{sprintf "%10s", sequence_name}"
    		end
    		sequence = ''
    		sequence_name = line.slice(1,11)
    	else
    		sequence << line
    	end
    end
    lines << ">#{sequence_name};1;;;;;;;"
    lines << sequence
    #lines << "#{sprintf "%10s", sequence_name}#{sequence}"

    if lines.length == 0
    	raise "No sequences found in #{ARGV[0]}, exiting."
    end

  	out = "  ;1.0\r\n"
  	(1..lines[1].length).each do |i|
  		out += "CH#{i};"
  	end
  	out += "\r\n"
  	(1..lines[1].length).each do |i|
  		out += "10;"
  	end
  	out += "\r\n"
  	lines.each { |l| out += "#{l}\r\n" }
  	out
  end

end
