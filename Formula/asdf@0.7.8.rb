class AsdfAT078 < Formula
  desc "Extendable version manager with support for Ruby, Node.js, Erlang & more"
  homepage "https://asdf-vm.com/"
  url "https://github.com/asdf-vm/asdf/archive/refs/tags/v0.7.8.tar.gz"
  sha256 "6225d822a189ab02f88e2afa9f46c52cb876885ea21b56827e564f73c99369d3"
  license "MIT"
  head "https://github.com/asdf-vm/asdf.git"

  keg_only :versioned_formula

  depends_on "autoconf"
  depends_on "automake"
  depends_on "coreutils"
  depends_on "libtool"
  depends_on "libyaml"
  depends_on "openssl@3"
  depends_on "readline"
  depends_on "unixodbc"

  def install
    bash_completion.install "completions/asdf.bash"
    fish_completion.install "completions/asdf.fish"
    zsh_completion.install "completions/_asdf"
    libexec.install "bin/private"
    prefix.install Dir["*"]
  end

  test do
    output = shell_output("#{bin}/asdf plugin-list 2>&1", 1)
    assert_match "Oohes nooes ~! No plugins installed", output
  end
end
