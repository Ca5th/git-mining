require 'open3'
require 'nokogiri'
require './git_commit'
require 'set'
require 'csv'
require 'pry'
class GitRepository
  
  attr_reader :repo_path
  
  def initialize(repo_path)
    @repo_path = repo_path
  end
  
  def get_commits
    results = ""
    Dir.chdir(@repo_path) do
      Open3.popen3('git log --pretty=format:"<hash>%H</hash><author>%ae</author><date>%ad</date><entry_separator>"') do |stdin, stdout, stderr, wait_thr|
        while line = stdout.gets
          results = results + line
        end
      end
    end
    commits = []
    results.split('<entry_separator>').each {|result| commits.push(GitCommit.new(result, self))}
    commits
  end  
end

