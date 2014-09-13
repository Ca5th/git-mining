require 'nokogiri'
require 'pry'
class GitCommit
  
  attr_reader :hash, :author, :repo, :date
  
  def initialize(result, repo)
    xml_doc  = Nokogiri::XML("<commit>" + result + "</commit>")
    hash_tag = xml_doc.xpath("//hash")
    author_tag = xml_doc.xpath("//author")
    date_tag = xml_doc.xpath("//date")
    
    @hash = hash_tag[0].content
    @author = author_tag[0].content
    @repo = repo
    @date = DateTime.parse(date_tag[0].content)
  end
  
  def get_touched_files
    commit_stats = ""
    Dir.chdir(@repo.repo_path) do
      Open3.popen3("git show --numstat --format='format:' " + @hash ) do |stdin, stdout, stderr, wait_thr|
        while line = stdout.gets
          commit_stats = commit_stats + line
        end
      end
    end
    
    touched_files = []
    
    commit_stats.each_line do |file_stats|
      if file_stats.split("\t").length == 3
        added_lines, deleted_lines, file_name = file_stats.split("\t")
        touched_files.push(file_name.strip)
      end
    end
    
    touched_files
  end
end