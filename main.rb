require 'rubygems'
require "csv"
require_relative 'lib/kmeans'
require_relative 'lib/geometric'
include Geometric
points = []
rng=Random.new(1234) #fixed seed

CSV.foreach("it-2004.sites.gpscoords.csv") do |row|
    #lat, long = row
    #puts "#{row}"
    node = Kmeans::Node.new(row,rng)
    points << node
end
k=ARGV[0].to_i or 4
puts "KMeans, k=#{k}"
clusters = Kmeans::cluster(points,k,rng)
#p clusters
puts "#{clusters.length} clusters created successfully."

#clusters.each {|c| 
#  c.nodes.each{|n| puts n}
#}