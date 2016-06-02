require 'phl_opa'
require 'date'
require "csv"

def insideoutside(block,boundary,full_address)
  # i.e. not a boundary property
  if boundary == "inside" or boundary == "outside"
    return boundary
  end
  
  if numlike = /(\d+th|\d+rd|Terrace)/i.match(block)
    stnum = numlike.captures[0]
    streettype = 'northsouth'
  else
    street = /\d+ (\S+)/.match(block).captures[0]
    #print "street: " + street + "\n"
    streettype = 'eastwest'
  end
  
  tags = /^(\d+)/.match(full_address).captures
  unit = tags[0]
  if streettype == 'eastwest'
    if unit.to_i.odd?
      streetside = "north"
    else
      streetside = "south"
    end
  else
    if unit.to_i.odd?
      streetside = "east"
    else
      streetside = "west"
    end
  end
  if streetside == boundary
    catchmentside = "outside"
  else
    catchmentside = "inside"
  end
  return catchmentside
end


#["property_id", "account_number", "full_address", "unit", "zip", "address_match", "geometry", "ownership", "characteristics", "sales_information", "valuation_history", "proposed_valuation"]

def doprops(props,block,boundary)
  for prop in props
    catchmentside = insideoutside(block,boundary,prop["full_address"])
    sqft =   prop["characteristics"]["improvement_area"]
    description = prop["characteristics"]["description"]
    myprops = prop["property_id"]+"\t"+prop["account_number"]+"\t"+prop["full_address"] + "\t" + sqft.to_s + "\t" + description.to_s + "\t" + catchmentside
    mydates  = Array.new
    myprices = Array.new
    numsales = 0
    for sales in prop["sales_information"]
      k,v = sales
      if k == 'sales_date'
        #/Date(1212120000000-0400)/
        if /\((\d+)/.match(v)
          datestrings = /\((\d+)/.match(v).captures
          datestring = datestrings[0]
          mydate = DateTime.strptime(datestring,'%Q').strftime("%Y-%m-%d")
        else
          mydate = ''
        end
        mydates << mydate
      elsif k == 'sales_price'
        myprice = v.to_s
        myprices << myprice
      end
    end
    mydates.zip(myprices).each do |thisdate, thisprice|
      print myprops + "\t" + thisdate + "\t" + thisprice + "\n"
    end
  end
end

print ["property_id", "account_number", "full_address", "sqft","description","catchment_side","sale_date","sale_price"].join("\t") + "\n"


CSV.foreach('data/properties/blocks.txt', :headers => true, :col_sep => "\t") do |csv_obj|
  resp=PHLopa.search_by_block(csv_obj['block'])
  if resp.key?("data")
    props=resp["data"]["properties"]
    $stderr.puts csv_obj['block'] + " results:" + props.length.to_s
    doprops(props,csv_obj['block'],csv_obj['boundary'])
  else
    $stderr.puts csv_obj['block']+": NO DATA"
  end
end

CSV.foreach('data/properties/addresses.txt', :headers => true, :col_sep => "\t") do |csv_obj|
  resp=PHLopa.search_by_address(csv_obj['address'])
  if resp.key?("data")
    props=resp["data"]["properties"]
    $stderr.puts csv_obj['address'] + " results:" + props.length.to_s
    if props.length > 0
      doprops(props,csv_obj['address'],csv_obj['boundary'])
    end
  else
    $stderr.puts csv_obj['address']+": NO DATA"
  end
end
#block, boundary, *the_rest = ARGV