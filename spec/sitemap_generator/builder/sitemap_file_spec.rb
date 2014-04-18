require 'spec_helper'

describe 'SitemapGenerator::Builder::SitemapFile' do
  let(:location) { SitemapGenerator::SitemapLocation.new(:namer => SitemapGenerator::SimpleNamer.new(:sitemap, :start => 2, :zero => 1), :public_path => 'tmp/', :sitemaps_path => 'test/', :host => 'http://example.com/') }
  let(:sitemap)  { SitemapGenerator::Builder::SitemapFile.new(location) }

  it "should have a default namer" do
    sitemap = SitemapGenerator::Builder::SitemapFile.new
    expect(sitemap.location.filename).to eq('sitemap1.xml.gz')
  end

  it "should return the name of the sitemap file" do
    expect(sitemap.location.filename).to eq('sitemap1.xml.gz')
  end

  it "should return the URL" do
    expect(sitemap.location.url).to eq('http://example.com/test/sitemap1.xml.gz')
  end

  it "should return the path" do
    expect(sitemap.location.path).to eq(File.expand_path('tmp/test/sitemap1.xml.gz'))
  end

  it "should be empty" do
    expect(sitemap.empty?).to be_true
    expect(sitemap.link_count).to eq(0)
  end

  it "should not be finalized" do
    expect(sitemap.finalized?).to be_false
  end

  it "should raise if no default host is set" do
    expect { SitemapGenerator::Builder::SitemapFile.new.location.url }.to raise_error(SitemapGenerator::SitemapError)
  end

  describe "lastmod" do
    it "should be the file last modified time" do
      lastmod = (Time.now - 1209600)
      sitemap.location.reserve_name
      File.expects(:mtime).with(sitemap.location.path).returns(lastmod)
      expect(sitemap.lastmod).to eq(lastmod)
    end

    it "should be nil if the location has not reserved a name" do
      File.expects(:mtime).never
      expect(sitemap.lastmod).to be_nil
    end

    it "should be nil if location has reserved a name and the file DNE" do
      sitemap.location.reserve_name
      File.expects(:mtime).raises(Errno::ENOENT)
      expect(sitemap.lastmod).to be_nil
    end
  end

  describe "new" do
    let(:original_sitemap) { sitemap }
    let(:new_sitemap)      { sitemap.new }

    before :each do
      original_sitemap
      new_sitemap
    end

    it "should inherit the same options" do
      # The name is the same because the original sitemap was not finalized
      expect(new_sitemap.location.url).to eq('http://example.com/test/sitemap1.xml.gz')
      expect(new_sitemap.location.path).to eq(File.expand_path('tmp/test/sitemap1.xml.gz'))
    end

    it "should not share the same location instance" do
      expect(new_sitemap.location).not_to be(original_sitemap.location)
    end

    it "should inherit the same namer instance" do
      expect(new_sitemap.location.namer).to eq(original_sitemap.location.namer)
    end
  end

  describe "reserve_name" do
    it "should reserve the name from the location" do
      expect(sitemap.reserved_name?).to be_false
      sitemap.location.expects(:reserve_name).returns('name')
      sitemap.reserve_name
      expect(sitemap.reserved_name?).to be_true
      expect(sitemap.instance_variable_get(:@reserved_name)).to eq('name')
    end

    it "should be safe to call multiple times" do
      sitemap.location.expects(:reserve_name).returns('name').once
      sitemap.reserve_name
      sitemap.reserve_name
    end
  end

  describe "add" do
    it "should use the host provided" do
      url = SitemapGenerator::Builder::SitemapUrl.new('/one', :host => 'http://newhost.com/')
      SitemapGenerator::Builder::SitemapUrl.expects(:new).with('/one', :host => 'http://newhost.com').returns(url)
      sitemap.add '/one', :host => 'http://newhost.com'
    end

    it "should use the host from the location" do
      url = SitemapGenerator::Builder::SitemapUrl.new('/one', :host => 'http://example.com/')
      SitemapGenerator::Builder::SitemapUrl.expects(:new).with('/one', :host => 'http://example.com/').returns(url)
      sitemap.add '/one'
    end
  end
end
