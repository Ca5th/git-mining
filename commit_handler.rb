require_relative './git_repository'

git_repo = ARGV[0]
subfolder = ARGV[1]

repo = GitRepository.new git_repo
commits = repo.get_commits

dev_file_pairs = Set.new
files = Set.new
authors = Set.new

commits.each do |commit|
  touched_files = commit.get_touched_files()
  
  touched_files.each do |file|
    if subfolder.nil? || file.start_with?(subfolder)
      files.add(file)
      authors.add(commit.author)
      dev_file_pairs.add({author: commit.author,
                        file: file})
    end
  end
end

files_array = files.to_a
authors_array = authors.to_a
author_files_matrix = Array.new(authors_array.length) { Array.new(files_array.length) }

#This generates the csv file that will be read by Conexp to generate the lattice drawing
File.open("conexp.csv", "w") do |file|
  file.write(" ;")
  files_array.each_index {|f| file.write("f" + f.to_s + ";") }
  file.write("\n")
  
  authors_array.each_index do |author_index|
                  file.write("a" + author_index.to_s + ";")
                  files_array.each_index do |file_index|
                    if dev_file_pairs.include?({author: authors_array[author_index],
                                                 file: files_array[file_index]})
                      author_files_matrix[author_index][file_index] = 1
                    else
                      author_files_matrix[author_index][file_index] = 0
                    end
                    file.write(author_files_matrix[author_index][file_index].to_s + ";")
                  end
                  file.write("\n")
  end
end

                
#This is to generate the file that will be read to generate the lattice with colibri
CSV.open("dev_file_pairs.csv", "w") do |csv|
  dev_file_pairs.each do |pair|
    file_index = files.find_index(pair[:file])
    author_index = authors.find_index(pair[:author])
    csv <<  ["a" + author_index.to_s, "f" + file_index.to_s]
  end
end
