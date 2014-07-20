#/bin/bash
rm k-means-result*txt
time ruby -rubygems main.rb 2    > k-means-result_k_2.txt
time ruby -rubygems main.rb 4    > k-means-result_k_4.txt
time ruby -rubygems main.rb 8    > k-means-result_k_8.txt
time ruby -rubygems main.rb 16   > k-means-result_k_16.txt
time ruby -rubygems main.rb 32   > k-means-result_k_32.txt
time ruby -rubygems main.rb 64   > k-means-result_k_64.txt
time ruby -rubygems main.rb 128  > k-means-result_k_128.txt
time ruby -rubygems main.rb 256  > k-means-result_k_256.txt
time ruby -rubygems main.rb 512  > k-means-result_k_512.txt
time ruby -rubygems main.rb 1024 > k-means-result_k_1024.txt

