class ConvertController < ApplicationController
  def index
  end
  
  def convert
    headers['Location'] = 'valid.rdf'
    unless params['convert']
      redirect_to '/', :notice => 'Please select a file'
    else
      begin
        render :text => fas_to_rdf(params['convert']['fas_file']), :status => 200, :content_type => 'application/octet-stream'
      rescue ConvertError => err
        redirect_to '/', :notice => err.to_str 
      end
    end
  end
  
  private
  
  class ConvertError < Exception
    attr_reader :sequence
    
    def initialize message, line_no = nil, _sequence=nil
      @sequence = _sequence
      @line_no = line_no
      @message = message
      
      super message
    end
    
    alias :to_str :message
    alias :to_str :to_s
    
    def to_str
      line_str = @line_no ? " on line #{@line_no}" : ''
        
      if @sequence
        "Error in conversion of sequence '#{@sequence}'#{line_str}: #{@message}"
      else
        "Conversion error#{line_str}: #{@message}"
      end
    end
  end
  
  
  NUCLEO = /[ACGTURYMKSWBDHVNGATC-]/ # http://users.ox.ac.uk/~linc1775/blueprint.htm
  A_NUCLEO = /([^ACGTURYMKSWBDHVNGATC-])/
  A_SEQUENCE_NAME = /([^\w _-])/
  
  def fas_to_rdf src_file 
    sequences = 0

    sequence_name = ''
    sequence = ''

    lines = []

    line_no = 0;
    src_file.read.split("\n").each do |line|
      line_no += 1;
    	line.gsub!("\r", "")
    	if line.start_with?('>')
    		if sequence.length > 0
    			lines << ">#{sequence_name};1;;;;;;;"    			    			
    			lines << sequence
    		else
    		  raise ConvertError.new("Zero-length sequence.", line_no - 1, sequence_name) if line_no != 1
    		end
    		sequence = ''
    		sequence_name = line.slice(1,11)
    		if sequence_name =~ A_SEQUENCE_NAME
    		  raise ConvertError.new("Invalid character (#{$1}) in sequence name.", line_no, sequence_name)
    		end
    		if sequence_name.blank?
    		  raise ConvertError.new("Blank sequence name.", line_no)
    		end
    	else
    	  sequence << line.upcase.gsub(' ', '')
    		
  			if sequence =~ /[01]/ && sequence =~ NUCLEO
  			  raise ConvertError.new("Found both binary and nucleotide data.", line_no, sequence_name)
  			end
  			
  			if sequence =~ /[01]/ && sequence =~ /([^01])/
  			  raise ConvertError.new("Found non-binary data (#{$1}) in a binary sequence.", line_no, sequence_name)
  			end
  			
  			if sequence =~ NUCLEO && sequence =~ A_NUCLEO
  			  raise ConvertError.new("Found non-nucleotide data (#{$1}) in a nucleotide sequence.", line_no, sequence_name)
  			end
  			
  			if sequence =~ A_NUCLEO && sequence =~ /[^01]/
  			  raise ConvertError.new("Could not find binary or nucleotide data.", line_no, sequence_name)
  			end
    	end
    end
		if sequence.length > 0
			lines << ">#{sequence_name};1;;;;;;;"    			    			
			lines << sequence
		else
		  raise ConvertError.new("Zero-length sequence.", line_no, sequence_name)
		end

    if lines.length == 0
    	raise ConvertException, "No sequences found in uploaded file."
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
