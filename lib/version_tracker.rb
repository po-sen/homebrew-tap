# typed: strict
# frozen_string_literal: true

require "json"
require "net/http"
require "rubygems"
require "timeout"
require "yaml"

# Fetches and normalizes upstream release tags for packages tracked by this tap.
module VersionTracker
  ROOT = File.expand_path("..", __dir__).freeze
  CONFIG_PATH = File.join(ROOT, "config", "tracked-packages.yml").freeze
  CATALOG_PATH = File.join(ROOT, "data", "upstream-versions.yml").freeze
  USER_AGENT = "po-sen-homebrew-tap-version-tracker"

  module_function

  def load_config
    YAML.load_file(CONFIG_PATH)
  end

  def packages
    load_config.fetch("packages")
  end

  def load_catalog
    return {} unless File.exist?(CATALOG_PATH)

    YAML.load_file(CATALOG_PATH)
  end

  def catalog_packages
    load_catalog.fetch("packages", {})
  end

  def present_string?(value)
    value.is_a?(String) && !value.empty?
  end

  def resolve_package_names(package_names)
    tracked_packages = packages
    selected_packages = package_names.empty? ? tracked_packages.keys : package_names
    unknown_packages = selected_packages - tracked_packages.keys

    abort "Unknown package(s): #{unknown_packages.join(", ")}" unless unknown_packages.empty?

    selected_packages
  end

  def fetch_github_tags(repo)
    owner, name = repo.split("/", 2)
    abort "Invalid GitHub repo: #{repo}" if !present_string?(owner) || !present_string?(name)

    tags = []
    page = 1

    loop do
      uri = URI("https://api.github.com/repos/#{owner}/#{name}/tags?per_page=100&page=#{page}")
      response = github_get(uri)

      unless response.is_a?(Net::HTTPSuccess)
        abort "GitHub API request failed for #{repo}: #{response.code} #{response.message}"
      end

      body = JSON.parse(response.body)
      break if body.empty?

      tags.concat(body.map { |tag| tag.fetch("name") })
      break if body.length < 100

      page += 1
    end

    tags
  end

  def github_get(uri)
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/vnd.github+json"
    request["User-Agent"] = USER_AGENT
    token = ENV.fetch("GITHUB_TOKEN", nil)
    request["Authorization"] = "Bearer #{token}" if present_string?(token)

    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  rescue SocketError, SystemCallError, Timeout::Error => e
    abort "Unable to reach GitHub API for #{uri.hostname}: #{e.message}"
  end

  def matching_versions(tags, pattern)
    regex = Regexp.new(pattern)

    versions = tags.each_with_object([]) do |tag, result|
      match = regex.match(tag)
      next unless match

      version = if match.names.include?("version")
        match[:version]
      else
        match[1] || match[0].delete_prefix("v")
      end

      result << version
    end

    versions.uniq.sort_by { |version| Gem::Version.new(version) }.reverse
  end

  def versions_for(package)
    upstream = package.fetch("upstream")

    matching_versions(
      fetch_github_tags(upstream.fetch("github")),
      upstream.fetch("tag_pattern"),
    )
  end

  def minor_latest_versions(versions)
    versions.group_by { |version| version.split(".").first(2).join(".") }
            .map { |_minor, minor_versions| minor_versions.first }
  end

  def minor_latest_versions_for(package_name, package)
    catalog_versions = catalog_packages.dig(package_name, "minor_latest_versions")
    return catalog_versions if catalog_versions.is_a?(Array) && !catalog_versions.empty?

    minor_latest_versions(versions_for(package))
  end

  def catalog
    tracked_packages = packages

    {
      "schema_version" => 1,
      "source"         => "github_tags",
      "packages"       => tracked_packages.each_with_object({}) do |(package_name, package), result|
        upstream = package.fetch("upstream")
        formulae = package.fetch("formulae")
        versions = versions_for(package)

        result[package_name] = {
          "upstream"              => upstream.fetch("github"),
          "latest"                => versions.first,
          "version_count"         => versions.length,
          "minor_latest_versions" => minor_latest_versions(versions),
          "primary_formula"       => formulae.fetch("primary"),
          "pinned_formulae"       => formulae.fetch("pinned", []),
          "versions"              => versions,
        }
      end,
    }
  end

  def catalog_yaml
    YAML.dump(catalog)
  end
end
