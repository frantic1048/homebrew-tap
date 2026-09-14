# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/Vanilla
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/Vanilla/tree/master/blend"
  version "0.2.15"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "f816b2b90e239f0d4fecb0fd53c1a26ef6887f2486c4703c2d778bc90a175ab1"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "0c4c25eb713da4802022cfaf68665d1c9f3053050bbc62e058f13256ea2b8127"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/frantic1048/Vanilla/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "3e270d5431036af61feaa6284b2202c8ff14aa57f4b1da9874c5593ab3d0e32c"
    else
      odie "blend is not available for this architecture"
    end
  end

  livecheck do
    url :stable
    regex(/^blend-v?(\d+(?:\.\d+)+)$/i)
  end

  def install
    bin.install Dir["*/blend"].first || "blend"
  end

  test do
    assert_match "blend #{version}", shell_output("#{bin}/blend --version")
  end
end
