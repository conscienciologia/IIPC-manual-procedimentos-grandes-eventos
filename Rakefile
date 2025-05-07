require 'net/http'
require 'rake/clean'
require 'find'
require 'date'
require 'open3'
require 'byebug'

task :default => [:wip]

SOURCE_FILES = FileList['livro/livro.asc', 'livro/*']
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`.strip
@RELEASE_DIR = "releases/#{CURRENT_BRANCH}"
@BOOK_SOURCE_DIR = 'livro'
@BOOK_SOURCE = 'livro/livro.md'
@BOOK_TARGET = 'livro/livro.pdf'
@PANDOC_BIN = `which pandoc`.strip
WIP_MD = "#{@BOOK_SOURCE_DIR}/wip.md"


RELEASE_BOOK_SOURCE="#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/livro.asc"
RELEASE_BOOK  =     "#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/livro.pdf"
RELEASE_WIP_MD =    "#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/wip.md"
RELEASE_WIP_PDF  =  "#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/wip.pdf"
RELEASE_DRAFT_MD =  "#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/draft.md"
RELEASE_DRAFT_PDF  ="#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/draft.pdf"
RELEASE_DRAFT_TEX  ="#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/draft.tex"


OPEN_PDF_CMD=`git config --get producao.pdfviewer`.strip

# A2X_COMMAND="-v -k -f pdf --icons -a docinfo1 -a edition=`git describe` -a lang=pt-BR -d book --dblatex-opts '-T computacao -P latex.babel.language=brazilian -P preface.tocdepth=1' -a livro-pdf"
A2X_COMMAND="-v -k -f pdf --icons -a docinfo1 -a edition=`git describe` -a lang=pt-BR -d book --dblatex-opts '-T computacao -P latex.babel.language=brazilian -P preface.tocdepth=1' -a livro-pdf"
# PANDOC_COMMAND="--standalone --toc --toc-depth=2 --number-sections --template=template/default.latex --latex-engine=lualatex --variable mainfont='Arial' --variable sansfont='Arial' --variable monofont='Courier New' --variable fontsize=12pt --variable version=`git describe` --variable date=`date +%d/%m/%Y` --variable author='Santana' --variable title='Livro' --variable lang=pt-BR --variable documentclass=report --variable classoption=brazil,12pt --variable papersize=a4 --variable geometry='left=3cm,right=2cm,top=3cm,bottom=2cm' --variable linkcolor=blue --variable urlcolor=blue --variable geometry=portrait --variable geometry=a4paper --variable geometry=left=3cm --variable geometry=right=2cm --variable geometry=top=3cm --variable geometry=bottom=2cm --variable geometry=portrait --variable geometry=a4paper --variable geometry=left=3cm --variable geometry=right=2cm --variable geometry=top=3cm --variable geometry=bottom=2cm --variable geometry=portrait"
PANDOC_COMMAND_TEX="--top-level-division=part --filter pandoc-latex-environment --standalone --toc --toc-depth=1 --template=template/default.latex --pdf-engine=lualatex --metadata-file=metadata.yaml wip.md --verbose -o wip.tex"
LATEXMK_CMD="latexmk -pdflatex=xelatex -f -pdf wip.tex"

A2X_EPUB_COMMAND="-v -k -f epub --icons -a docinfo1 -a edition=`git describe` -a lang=pt-BR -d book "
PROJECT_NAME = File.basename(Dir.getwd)
LIVRO_URL = `git config --get livro.url`.strip
GITHUB_REPO = `git config remote.origin.url`.strip.gsub('git@github.com:','').gsub('.git','')

# release
REPOSITORIO_PATH=`git rev-parse --show-toplevel`.strip
#@RELEASE_DIR = ''
@tag = ''
@SEJDA_BIN = '/home/santana/ambiente/sejda/bin/sejda-console'

directory @RELEASE_DIR

CLEAN.include('releases')

desc "Sync, build and open wip file"
task :wip => [WIP_MD, "sync", "wip:build", "wip:open"]
task :edit => ["wip:edit"]
task :epub

namespace "wip" do

  file @BOOK_SOURCE

  desc "Create new wip file from book source"
  task "new" do
    cp "#{@BOOK_SOURCE}", WIP_MD
  end

  file WIP_MD => [@BOOK_SOURCE] do
    Rake::Task["wip:new"].invoke
  end

  file RELEASE_WIP_PDF
  desc "build book from #{@RELEASE_DIR}"
  task :build => [WIP_MD, :sync] do
    DRAFT_COMMAND = "" # "--dblatex-opts '-P draft.mode=yes'"
    prefacio_code_att = ""
    # PREFACIO_CODE_DIR = "#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/code/prefacio"
    # if Dir.exist?(PREFACIO_CODE_DIR) then
    #   Dir.chdir(PREFACIO_CODE_DIR) do
    #     prefacio_code_file = Dir.glob("*").first
    #     if (prefacio_code_file) then
    #       prefacio_code_att = "-a prefacio-code=#{prefacio_code_file}"
    #     end
    #   end
    # end
    Dir.chdir(@RELEASE_DIR + '/livro') do
      system "#{@PANDOC_BIN} #{PANDOC_COMMAND_TEX} #{DRAFT_COMMAND}"
      if File.exist?("wip.tex") then
        system "#{LATEXMK_CMD} #{DRAFT_COMMAND}"
      end
    end
  end

  desc "Open wip pdf"
  task :open => RELEASE_WIP_PDF do |t|
      puts "#{OPEN_PDF_CMD} #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/wip.pdf"
      system "#{OPEN_PDF_CMD} #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/wip.pdf"
  end

  desc "Open docbook xml from wip build"
  task "xml" => ["#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/wip.xml"] do
    system "#{OPEN_PDF_CMD} #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/wip.xml"
  end

  desc "Edit wip source"
  task "edit" do
    system "gvim #{WIP_MD}"
  end


  desc "build wip epub book"
  task :epub do
    system "#{@PANDOC_BIN} #{A2X_EPUB_COMMAND} #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/wip.adoc"
  end


end

DRAFT_MD = "#{@BOOK_SOURCE_DIR}/draft.md"
DRAFT_RELEASE = [:md, :tex, :pdf].to_h{|k| [k, "#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/draft.#{k}"]}
DRAFT_RELEASE[:template] = "#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/template/draft.latex"
DRAFT_TEMPLATE = "#{@BOOK_SOURCE_DIR}/template/draft.latex"

task :draft => [DRAFT_MD, "sync", "draft:build", "draft:open"]
namespace "draft" do

  file @BOOK_SOURCE
  file DRAFT_TEMPLATE

  desc "Create new wip file from book source"
  task "new" do
    cp "#{@BOOK_SOURCE}", DRAFT_MD
  end

  file DRAFT_MD => [@BOOK_SOURCE] do
    Rake::Task["draft:new"].invoke
  end

  file DRAFT_RELEASE[:tex] => [DRAFT_MD, DRAFT_TEMPLATE] do |t|
    Dir.chdir(@RELEASE_DIR + '/livro') do
      system "pandoc --filter pandoc-latex-environment --standalone --bibliography  bibliografia.json --template=template/draft.latex --pdf-engine=xelatex --metadata-file=metadata.yaml draft.md --verbose -o draft.tex"
    end
  end

  file DRAFT_RELEASE[:pdf] => DRAFT_RELEASE[:tex] do |t|
    Dir.chdir(@RELEASE_DIR + '/livro') do
      system "latexmk -pdflatex=xelatex -f -pdf draft.tex"
    end
  end

  task :pdf => DRAFT_RELEASE[:pdf]
  task :tex => DRAFT_RELEASE[:tex]

  desc "build book from #{@RELEASE_DIR}"
  task :build => [DRAFT_MD, :sync, 'draft:tex', 'draft:pdf']

  desc "Open wip pdf"
  task :open => RELEASE_WIP_PDF do |t|
      puts "#{OPEN_PDF_CMD} #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/draft.pdf"
      system "#{OPEN_PDF_CMD} #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/draft.pdf"
  end
end



desc "Archive, build and open book file"
task :book => [:clean, :archive, "book:build", "book:open"]

namespace "book" do

  desc "Build book"
  task :build => ['sync'] do
    system "#{@PANDOC_BIN} #{A2X_COMMAND} #{@RELEASE_DIR}/#{@BOOK_SOURCE}"
  end

  desc "Open pdf book"
  task "open" do
    system "#{OPEN_PDF_CMD} #{@RELEASE_DIR}/#{@BOOK_TARGET}"
  end

  desc "Open docbook xml from book build"
  task "xml" do
    system "#{OPEN_PDF_CMD} #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/livro.xml"
  end

  desc "Edit book source"
  task "edit" do
    system "gvim #{@BOOK_SOURCE}"
  end

  desc "Release new edition book"
  task :release, [:tag] do |t, args|
    #PROJECT = sh "`git config --get remote.origin.url | cut -f 2 -d / | cut -f 1 -d .`"
    puts "PROJECT_NAME='#{PROJECT_NAME}' LIVRO_URL='#{LIVRO_URL}'"
    mkdir_p "~/releases/#{PROJECT_NAME}"
    cd "~/releases/#{PROJECT_NAME}"
    `wget #{LIVRO_URL}`
    puts "Salvando arquivo em #{Dir.getwd}"
    mv "livro.pdf", "#{PROJECT_NAME}-#{args.tag}.pdf"
    #Dir.mkdir(File.join(Dir.home, ".foo"), 0700)
  end

end

desc "Extract files from repository (git archive)"
task :archive => :clean do
  system "git archive --format=tar --prefix=#{@RELEASE_DIR}/ HEAD | (tar xf -) "
end

desc "Local sync of the files"
task :sync => @RELEASE_DIR do |t|
  system "rsync -r --delete #{@BOOK_SOURCE_DIR}/ #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}"
end

namespace "tag" do

  desc "List project tags"
  task :list do
    sh "git tag --list"
  end

  desc "Aplly a tag to the project. The tag can be used as the edition."
  task :apply, [:tag] do |t, args|
    sh "git status"
    sh "git tag -a #{args.tag} -m 'Gerando versão #{args.tag}'"
  end

  desc "Delete a tag applied."
  task :delete, [:tag] do |t,args|
    sh "git tag -d #{args.tag}"
  end

  desc "Push tags"
  task "push" do
    sh "git push origin"
    sh "git push origin --tags"
  end

  desc "Generate revision history, compare HEAD and tag.
  The tag is optional, if not specified it will use the last tag applied."
  task :revision, [:tag] do |t, args|
    last_tag = `git describe --abbrev=0`.strip
    args.with_defaults(:tag => last_tag)
    tag = args.tag
    edition = ENV.fetch('edition', "#{tag} FIXME!")
    authors = ENV.fetch('authors', " FIXME! ")
    date = Date.today.strftime "%d/%m/%Y"
    history, s = Open3.capture2("git log --reverse --format='- %s. ' #{args.tag}..HEAD")
    revision = "\n
<revision>
  <revnumber>#{edition}</revnumber>
  <date>#{date}</date>
  <authorinitials>#{authors}</authorinitials>
  <revremark>
#{history}      </revremark>
</revision>\n\n"
    puts revision
  end

  desc "Open docinfo for edition.
  Before apply tag you should edit docinfo and add the revision history."
  task :docinfo do
    puts "#{OPEN_PDF_CMD} #{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/wip.pdf"
    system "xdg-open #{@BOOK_SOURCE_DIR}/docinfo.xml"
  end

end


desc "Open orginal pdf to work"
task :original do
    sh "#{OPEN_PDF_CMD} original/original.pdf"
end


namespace "config" do

#  desc "Configure open command. `xdg-open` for ubuntu and open for `osx`"
  task :pdfviewer, [:app] do |t,args|
    sh "git config --global producao.pdfviewer #{args.app}"
  end

end

desc "Build images from R files"
task :r
task :sync => :r

FileList['livro/images/**/*.R'].each do |source|
  rpdf = source.ext('pdf')
  file rpdf => source do |t|
    rm_rf "Rplots.pdf"
    sh "R --no-save < #{t.source}"
    mv "Rplots.pdf","#{t.name}"
  end
  task :r => rpdf
end

namespace "github" do
  desc "List issues from github milestone. Default milestone state is closed, can also be all."
  task :issues, [:milestone] do |t,args|
    puts "Acessing: #{GITHUB_REPO} milestone=#{args.milestone}"
    require 'octokit'
#    require 'highline/import'
    client = Octokit::Client.new
    milestone = nil
    milestones = client.list_milestones(GITHUB_REPO, state: 'all', sort: 'created', direction: 'desc')
    opcoes = milestones.map {|m| m[:title]}

    if (args.milestone) then
      #puts "milestones: #{milestones}"
      milestones.each do |m|
        if m[:title] == args.milestone then
          milestone = m
        end
      end
    else
      milestone = milestones[0]
    end
    puts "Milestone: #{milestone[:title]} #{milestone[:state].upcase}"

    puts ""
    puts "Para adicionar ao docinfo.xml:\n"
    issues = client.list_issues(GITHUB_REPO, milestone:milestone[:number], sort: 'created', direction: 'asc', state:'all')
    open_issues = []
    issues.each do |i|
      if (i[:state] == 'open') then
        open_issues << i[:number]
      end
    end
    if (open_issues.size > 0) then
      puts "Open issues: #{open_issues}"
      puts ""
    end
    issues.each do |i|
      puts "<ulink url=\"{gitrepo}/issues/#{i[:number]}\">#{i[:title]};</ulink>"
    end
    puts ""
    puts "Para adicionar ao release notes no github:"
    issues.each do |i|
      puts "- #{i[:title]} (##{i[:number]});"
    end

    puts ""
    puts "Para commits:"
    issues.each do |i|
      puts "#{i[:title]} closes ##{i[:number]}"
    end


  end
end


namespace "release" do

  desc "Archive files from git tag. If not tag is passed, the last tag applied will be used."
  task :archive, [:tag] do |t, args|
    last_tag = `git describe --abbrev=0`.strip
    args.with_defaults(:tag => last_tag)
    @tag = args.tag
    @RELEASE_DIR = "releases/#{args.tag}"
    system "git archive --format=tar --prefix=#{@RELEASE_DIR}/ #{@tag} | (tar xf -) "
  end

  desc "Build book release. If not tag is passed, the last tag applied will be used."
  task :build, [:tag] do |t, args|
    last_tag = `git describe --abbrev=0`.strip
    args.with_defaults(:tag => last_tag)
    @tag = args.tag
    @RELEASE_DIR = "releases/#{args.tag}"
    release_dir = "releases/#{args.tag}"
    target_file = "releases/#{PROJECT_NAME}-#{@tag}.pdf"
    ficha_file = "#{release_dir}/livro/editora/ficha-#{args.tag}.pdf"
    if File.exist?(ficha_file) then
      editora_file = ficha_file
    else
      puts "Using 'editora.pdf' instead of ficha-#{args.tag}.pdf"
      editora_file = "#{release_dir}/livro/editora/editora.pdf"
    end
    livro_source = "#{release_dir}/livro/livro.asc"
    livro_pdf = "#{release_dir}/livro/livro.pdf"
    
    prefacio_code_att = ""
    PREFACIO_CODE_DIR = "#{@RELEASE_DIR}/#{@BOOK_SOURCE_DIR}/code/prefacio"
    if Dir.exist?(PREFACIO_CODE_DIR) then
      Dir.chdir(PREFACIO_CODE_DIR) do
        prefacio_code_file = Dir.glob("*").first
        if (prefacio_code_file) then
          prefacio_code_att = "-a prefacio-code=#{prefacio_code_file}"
        end
      end
    end

    directory release_dir
    file livro_source => [release_dir]
    file livro_pdf => [livro_source] do
      Dir.chdir(@RELEASE_DIR) do
        @A2X_COMMAND="-v -k -f pdf --icons -a docinfo1 -a edition=#{@tag} -a lang=pt-BR -d book --dblatex-opts '-T computacao -P latex.babel.language=brazilian' --dblatex-opts '-P show.comments=0' -a livro-pdf #{prefacio_code_att}"
        system "#{@PANDOC_BIN} #{@A2X_COMMAND} livro/livro.asc"
      end
    end
    file target_file => [livro_pdf] do
      if File.exist? editora_file then
        system "#{@SEJDA_BIN} merge -f #{editora_file} #{livro_pdf} -o #{target_file}"
      else
        mv livro_pdf, target_file
      end
    end

    Rake::Task[target_file].invoke()

  end # build

end

namespace 'template' do
  
  directory 'template'
  file 'template/default.latex'
  desc "Create a new book template from pandoc"
  task :new, ['template', 'template/default.latex'] do |t,args|
    system "pandoc -D latex > template/default.latex"
  end
end