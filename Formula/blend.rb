# typed: false
# frozen_string_literal: true

# Formula for blend — a dotfiles manager powered by Nickel DSL.
# https://github.com/frantic1048/blend
class Blend < Formula
  desc "Dotfiles manager powered by Nickel DSL"
  homepage "https://github.com/frantic1048/blend"
  version "0.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-aarch64-apple-darwin.tar.xz"
    sha256 "a3b48f4b3c166f927d558e3e8bba529abc92b9f0ff51a558769c59d84b465bb4"
    elsif Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-apple-darwin.tar.xz"
    sha256 "2f1f79869e5aadca976e371db05a922e3c59248d178bdaa09e8e031320757bdc"
    else
      odie "blend is not available for this architecture"
    end
  end

  on_linux do
    if Hardware::CPU.intel?
      url "https://github.com/frantic1048/blend/releases/download/blend-v#{version}/blend-x86_64-unknown-linux-gnu.tar.xz"
    sha256 "86573ada0e4fd5d7470df1a83a9c609159589dc3dd83ba7e2941ee64dfa054a0"
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
