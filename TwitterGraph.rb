#!/usr/bin/ruby

puts "Iniciando..."

require 'rubygems'
require 'twitter'
require "graphviz"

def main()
  @analisados = get_analisados()
  puts "Autenticando..."
  user = "_polo"
  senha = "*****"
  @eu = Twitter::Base.new(Twitter::HTTPAuth.new(user, senha))

  begin
    puts "Pegando amigos..."
    sigo_nomes = @eu.friends.collect{|x| x.screen_name}
    sigo_nomes << user

    puts "Fazendo gráfico..."
    g = GraphViz::new( "G", :type => "digraph")
    g.node[:color]    = "#ddaa66"
    g.node[:style]    = "filled"
    g.node[:penwidth] = "1"
    g.node[:fontname] = "Trebuchet MS"
    g.node[:fontsize] = "8"
    g.node[:fillcolor]= "#ffeecc"
    g.node[:margin]   = "0.0"
    g[:overlap] = false
    
    sigo_nomes.each {|sigo| g.add_node(sigo, :fillcolor=>"#ffffcc")}
    sigo_nomes.each do |sigo|
      sigo_nomes.each do |segue|
        if self.segue?(sigo, segue)
          sigo_node = g.get_node(sigo)
          segue_node = g.get_node(segue)
          g.add_edge(sigo_node, segue_node)
        end
      end
    end
  
  rescue Twitter::RateLimitExceeded
    puts "\n== Limite! Tenta em 1 hora ==\n\n"
  end

  if g
    puts "\nSalvando..."
    g.output( :png => "result-circo.png", :use=>:circo)
    puts "Salvo!"
  end
end

def self.segue?(sigo, segue)
  return false if sigo==segue
  puts "#{sigo} -> #{segue} ?"
  dado = @analisados.index("#{sigo}->#{segue}")
  @response = false
  if dado
    @response = @analisados[dado+1] == "false" ? false : true
  else
    @response = @eu.friendship_exists?(sigo, segue)
    File.open('data.txt', 'a') do |file|
      file << "#{sigo}->#{segue}\n"
      file << @response.to_s+"\n"
    end
  end
  puts @response
  return @response
end

def get_analisados()
  data = ''
  f = File.open("data.txt", "r")
  f.each_line {|line| data += line }
  return data.split("\n")
end

main()