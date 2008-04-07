require File.join(File.dirname(__FILE__), 'spec_helper')

describe Gemify::Base do
  include BaseHelper
  
  before(:each) do
    @files = ["bin/program", "bin/dir/program", "lib/lib.rb",
      "lib/bin/program", "lib/extconf.rb", "lib/extconf.rb/file.yml"]
    @base = Gemify::Base.new(@files)
  end
  
  it "should accept all files" do
    @base.files.should == @files
  end
  
  it "should determine binaries" do
    @base.binaries.should == ["bin/program"]
  end
  
  it "should determine extensions" do
    @base.extensions.should == ["lib/extconf.rb"]
  end
  
  it "should be able to set all settings and read them through #[]" do
   @base.settings = dummy
   
   @base.settings.keys.each do |key|
     @base[key].should == dummy[key]
   end
  end
  
  it "should set settings properly" do
    @base[:version] = 0.2
    @base[:has_rdoc] = "test"
    @base[:dependencies] = "rubygems"
    
    @base[:version].should == "0.2"
    @base[:has_rdoc].should == true
    @base[:dependencies].should == ["rubygems"]
  end
  
  it "should set settings properly through #settings=" do
    @base.settings = {
      :version => 0.2,
      :has_rdoc => "test",
      :dependencies => "rubygems"
    }
    
    @base[:version].should == "0.2"
    @base[:has_rdoc].should == true
    @base[:dependencies].should == ["rubygems"]
  end                              
  
  it "should delete settings properly" do
    @base[:name] = ""
    @base[:version] = nil
    @base[:has_rdoc] = false
    @base[:dependencies] = []
    
    @base[:name].should == nil
    @base[:version].should == nil
    @base[:has_rdoc].should == nil
    @base[:dependencies].should == nil
  end
  
  it "should ignore other settings" do
    @base[:extensions] = true
    @base[:extensions].should == nil
  end
  
  it "should not be valid without the required settings" do
    @base.valid?.should == false
  end
  
  it "should be valid with the required settings" do
    @base[:name] = "Magnus Holm"
    @base[:version] = "0.9"
    @base[:summary] = "A nice little summary"
    @base.valid?.should == true
  end
  
  it "should return the right setting type" do
    @base.type(:name).should == :string
    @base.type(:has_rdoc).should == :boolean
    @base.type(:dependencies).should == :array
  end                                         
  
  it "should return the correct setting name" do
    @base.name(:name).should == "name"
    @base.name(:has_rdoc).should == "documentation"
    @base.name(:rubyforge_project).should == "RubyForge project"
  end
  
  it "should cast the setting properly" do
    @base.cast(:version, 0.2).should == "0.2"
    @base.cast(:has_rdoc, "test").should == true
    @base.cast(:dependencies, "rubygems").should == ["rubygems"]
  end 
  
  it "should show the setting" do
    @base.settings = dummy
    @base.show(:name).should == "gemify"
    @base.show(:dependencies).should == "rubygems, merb-core"
    @base.show(:has_rdoc).should == "true"
  end
  
  it "should make proper specification" do
    d = dummy
    @base.settings = d
    spec = @base.specification
    spec.should.is_a? Gem::Specification
    
    spec.dependencies.map{ |x| x.name }.should == d.delete(:dependencies)
    spec.version.to_s.should == d.delete(:version)
    
    d.keys.each do |key|
      spec.send(key).should == d[key]
    end
    spec.extensions.should == ["lib/extconf.rb"]
    spec.executables.should == ["program"]
  end
end