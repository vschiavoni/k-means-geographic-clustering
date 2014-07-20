require_relative 'geometric'

module Kmeans
  # TODO: Error and validity checks for objects
  
  MAX_ITERATIONS = 10
  
  class Node

    attr_accessor :lat, :lon

    def initialize(coordinates,rng)

      lon, lat = coordinates
      if not lat or not lon
        raise Exception.new('Coordinates not provided to Node')
      end
      #Add some noise to the coordinates, the GeoIP service has a low-resolution, many duplicates
      @lon ||= lon.to_f + (Random.rand(0.0000000000001..0.0000009)*[-1,1].sample(random:rng)) 
      @lat ||= lat.to_f + (Random.rand(0.0000000000001..0.0000009)*[-1,1].sample(random:rng))

    end

  end

  class Cluster

    attr_accessor :nodes, :centroid, :rng

    def initialize(nodes,rng)
      if not nodes
        raise Exception.new('Nodes not provided to Cluster')
      end
      @nodes = nodes
      @rng = rng
      @centroid = calculate_centroid()
    end

    def update(nodes)
      # TODO: Use .send() to allow passing of other distance calculations
      #puts"Updating cluster with #{nodes.length} nodes, currently there are #{@nodes.length}"
      @nodes = nodes
      old_centroid = @centroid
      @centroid = calculate_centroid()
      centroid_shift = haversine_distance(old_centroid, @centroid)
      return @centroid==old_centroid, centroid_shift
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
    
    convergence_loops=0
    loop do  #loop until k-means converged (TODO: implement OR MAX_ITERATIONS)
      
      lists.each{|l| l.clear} #remove elements from previous run      
      
      convergence_loops +=1
      index += 1
      
      points.each do |point|
        index_shortest=0
        smallest_distance=-1
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
      
      for i in 0..(n-1)
        cluster_i = clusters[i]
        is_centroid_same, shift = cluster_i.update(lists[i]) #update the centroids and check if it moved
        if not is_centroid_same then
          biggest_shift = shift if shift > biggest_shift # how much did the centroid move?   
        end
      end
      break if biggest_shift < cutoff or (convergence_loops >= MAX_ITERATIONS)      
    end
    for i in 0..(n-1) 
      l=lists[i]
      puts "#### Nodes in cluster #{i}: #{l.length} ####"
      #l.each{|n| puts "#{i} #{n.lon}" << " " << "#{n.lat}" }      
    end
      
    puts "Loops required to converge: #{convergence_loops} (MAX:#{MAX_ITERATIONS})"
   
    return clusters
    
  end

end
