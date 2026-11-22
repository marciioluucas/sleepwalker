# Homebrew formula for the tap repo (github.com/marciioluucas/homebrew-tap → Formula/sleepwalker.rb).
# Release: tag vX.Y.Z, then fill url/sha256 (shasum -a 256 of the tarball).
class Sleepwalker < Formula
  desc "Keep your Mac awake with the lid closed while your AI coding agent works"
  homepage "https://github.com/marciioluucas/sleepwalker"
  url "https://github.com/marciioluucas/sleepwalker/archive/refs/tags/v0.2.2.tar.gz"
  sha256 "73849fc86c11d83382613d6cdf1317bcdfb65e810efe3e9b4100700599b39edf"
  license "MIT"

  depends_on :macos

  def install
    # swk finds the daemon at <prefix>/libexec, next to <prefix>/bin
    bin.install "bin/swk"
    libexec.install "libexec/sleepwalker-daemon", "libexec/sleepwalker-root"
    pkgshare.install "skills", "docs"
  end

  def caveats
    <<~EOS
      Finish with (asks for your password once — installs the daemon and a narrow sudoers rule):
        swk setup

      Claude Code skill:
        mkdir -p ~/.claude/skills/sleepwalker
        cp #{opt_pkgshare}/skills/sleepwalker/SKILL.md ~/.claude/skills/sleepwalker/

      Before `brew uninstall sleepwalker`, run: swk uninstall
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/swk --version")
  end
end
