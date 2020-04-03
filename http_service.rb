require 'socket'
require 'csv'
require 'json'

prices = CSV.read("#{File.dirname(__FILE__)}/02_ruby_prices.csv").to_h
server = TCPServer.new 5678

def query_reading(request)
  return nil unless request.include?('?')
  params = {}
  hdd_params = []
  request = request.split('?').last.split('&')

  hdd_query, cpu_ram_query = request.partition{ |x| x.include? "hdd" }

  hdd_query.each { |param| hdd_params << param.split('=').last }

  cpu_ram_query.each do |param|
    param = param.split('=')
     key = param[0]
     value = param[1]
    params[key] = JSON.parse(value)
  end
   params.merge!({"add" => hdd_params.each_slice(2).to_a})
end


def vm_price(vm, price_list)
  price = 0
  vm.each do |type, value|
    if value.is_a?(Array)
      value.each do |additional_hdd|
        type = additional_hdd[0]
        capacity = additional_hdd[1].to_i

        price += price_list[type].to_i * capacity
      end
    else
      price += price_list[type].to_i * value
    end
  end
  price
end

while session = server.accept
   request = session.gets.split(' ')[1]
   puts request

   session.print "HTTP/1.1 200\r\n"
   session.print "Content-Type: text/html\r\n"
   session.print "\r\n"

  vm =  query_reading(request)
  session.print "The cost of the VM will be #{vm_price(vm, prices)/100} rub." if vm
  session.print "Parameters not set" unless vm

   session.close
end
