require_relative 'geometric'

module Kmeans
  # TODO: Error and validity checks for objects

  class Node

    attr_accessor :lat, :lon

    def initialize(coordinates,rng)

      lon, lat = coordinates
      if not lat or not lon
        raise Exception.new('Coordinates not provided to Node')
      end
      #Add some noise to the coordinates, the GeoIP service has a low-resolution, many duplicates
      @lon ||= lon.to_f + (Random.rand(0.00000000001..0.0000009)*[-1,1].sample(random:rng)) 
      @lat ||= lat.to_f + (Random.rand(0.00000000001..0.0000009)*[-1,1].sample(random:rng))

    end

  end

  class Cluster

    attr_accessor :nodes, :centroid, :rng

    def initialize(nodes,rng)
      if not nodes
        raise Exception.new('Nodes not provided to Cluster')
      end
      @nodes ||= nodes
      @rng = rng
      @centroid = calculate_centroid()
    end

    def update(nodes)
      # TODO: Use .send() to allow passing of other distance calculations
      @nodes = nodes
      old_centroid = @centroid
      @centroid = calculate_centroid()
      haversine_distance(old_centroid, new_centroid)
    end

    def calculate_centroid()
      total_lat, total_lon = 0, 0

      @nodes.each do |node|
        total_lat += node.lat
        total_lon += node.lon
      end

      n = @nodes.length
      Node.new([total_lon/n, total_lat/n],@rng)

    end
    
    def add_node(n)
      @nodes << n
    end

  end


  def Kmeans.cluster(points, n, rng)
    raise "Invalid points" unless points.length > 0
    raise "Invalid number of clusters " unless n > 1
    
    initial_seeds = points.sample(n,random: rng) # Ruby 1.9 required
    # Create a one-point Cluster for each seed
    clusters = []
    cutoff = 1

    initial_seeds.each do |node|
      cluster = Cluster.new([node],rng)
      clusters << cluster
    end

    index = 0
    
    lists = []
    for i in 1..n #one list per cluster?
      lists << []
    end
    
    loop do
      index += 1
      
      points.each do |point|
        index_shortest=0
        smallest_distance=-1
        #smallest_distance = haversine_distance(point, clusters[0].centroid)
        #puts "Initial smallest distance from #{point} to centroid: #{clusters[0].centroid} #{smallest_distance}"
        cluster_index=0
        clusters.each do |cluster|
          distance = haversine_distance(point, cluster.centroid)
          #puts "Point #{point.lon}:#{point.lat} Cluster centroid : #{cluster.centroid.lon}:#{cluster.centroid.lat} distance: #{distance}"
          
          if (smallest_distance < 0) or (distance < smallest_distance) 
            smallest_distance = distance
            index_shortest=cluster_index
          end
          cluster_index+=1  
        end
        #puts "Assigning point to cluster #{index_shortest}"
        lists[index_shortest] << point
      end

      biggest_shift = 0.0
      clusters.each do |cluster|
        shift = clusters # how much did the centroid move?
      end
      
      break if biggest_shift < cutoff
      
    end
    c=0
    lists.each{|l| 
      puts "Nodes in cluster #{c}: #{l.length}"
      c +=1
    } 
    return clusters
    
  end

end
