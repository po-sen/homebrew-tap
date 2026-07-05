class AsdfAT0120 < Formula
  desc "Extendable version manager with support for Ruby, Node.js, Erlang & more"
  homepage "https://asdf-vm.com/"
  url "https://github.com/asdf-vm/asdf/archive/refs/tags/v0.12.0.tar.gz"
  sha256 "8416d3556f093b3f2f9931b30165efd8800c520c129bed22a537f889aa6dff90"
  license "MIT"
  head "https://github.com/asdf-vm/asdf.git", branch: "master"

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
    libexec.install Dir["*"]
    touch libexec/"asdf_updates_disabled"

    bin.write_exec_script libexec/"bin/asdf"
  end

  def caveats
    <<~EOS
      To use asdf, add the following line (or equivalent) to your shell profile
      e.g. ~/.profile or ~/.zshrc:
        . #{opt_libexec}/asdf.sh
      e.g. ~/.config/fish/config.fish
        source #{opt_libexec}/asdf.fish
      Restart your terminal for the settings to take effect.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/asdf version")
    output = shell_output("#{bin}/asdf plugin-list 2>&1", 1)
    assert_match "No plugins installed", output
    assert_match "Update command disabled.", shell_output("#{bin}/asdf update", 42)
  end
end
