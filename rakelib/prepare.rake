original_source_file = Rake::FileList.new('original/original.docx')

directory 'livro'
file 'livro/livro.docx' => ['livro', 'original/original.docx'] do |t|
  cp 'original/original.docx', 'livro/livro.docx'
end

file 'livro/livro.md' => ['livro/livro.docx'] do |t|
  Dir.chdir("livro") do
    sh "pandoc --wrap=none -s --extract-media=. livro.docx -o livro.md"
  end
end

source_file = 'livro/livro.md'

desc "Prepare initial files from docx"
task :prepare => ['livro/livro.md']
